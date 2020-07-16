import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:filmix_watch/settings.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/subjects.dart';
import 'package:path/path.dart' as p;

class DownloadManager {
  static Map<String, DownloadItem> downloadMap = {};
  static List<DownloadItem> downloadItems = [];
  static BehaviorSubject _controller = BehaviorSubject();
  static BehaviorSubject get updateController => _controller;

  static ReceivePort _port;

  static init() async {
    await Hive.openBox('download');
    await reloadTasks();

    _initDownloader();
  }

  static Future reloadTasks() async {
    var box = Hive.box('download');
    var tasks = await FlutterDownloader.loadTasks();
    downloadItems.clear();
    for (var task in tasks
      ..sort(
        (a, b) => b.timeCreated.compareTo(a.timeCreated),
      )) {
      var data = jsonDecode(
        box.get('download-${task.taskId}', defaultValue: '{}'),
      ) as Map;
      if (data.length != 4) {
        await FlutterDownloader.remove(taskId: task.taskId);
      } else {
        downloadItems.add(DownloadItem(
          task: task,
          name: data['name'],
          episode: data['episode'],
          isSerial: data['isSerial'],
          quality: data['quality'],
        ));
      }
    }

    _controller.add(null);
  }

  static Future<bool> open(DownloadItem item) async {
    return FlutterDownloader.open(
      taskId: item.task.taskId,
    );
  }

  static Future pause(DownloadItem item) async {
    await FlutterDownloader.pause(
      taskId: item.task.taskId,
    );
    await reloadTasks();
  }

  static Future resume(DownloadItem item) async {
    var box = Hive.box('download');
    var data = box.get('download-${item.task.taskId}');
    box.delete('download-${item.task.taskId}');
    var taskId = await FlutterDownloader.resume(
      taskId: item.task.taskId,
    );
    box.put('download-$taskId', data);
    await reloadTasks();
  }

  static Future cancel(DownloadItem item) async {
    var box = Hive.box('download');
    box.delete('download-${item.task.taskId}');
    await FlutterDownloader.cancel(
      taskId: item.task.taskId,
    );
    await reloadTasks();
  }

  static Future retry(DownloadItem item) async {
    var box = Hive.box('download');
    var data = box.get('download-${item.task.taskId}');
    box.delete('download-${item.task.taskId}');
    var taskId = await FlutterDownloader.retry(
      taskId: item.task.taskId,
    );
    box.put('download-$taskId', data);
    await reloadTasks();
  }

  static Future remove(DownloadItem item, bool shouldDeleteContent) async {
    await FlutterDownloader.remove(
      taskId: item.task.taskId,
      shouldDeleteContent: shouldDeleteContent,
    );
    await reloadTasks();
  }

  static bool hasInDownloads(String url) {
    return downloadItems.where((e) => e.task.url == url).isNotEmpty;
  }

  static download({
    String url,
    String name,
    String episode = "",
    bool isSerial = true,
    String quality,
  }) async {
    var fileName = '$name';
    if (isSerial) {
      fileName += ' $episode';
    }
    fileName += ' [$quality]';

    var directory = Directory(
      isSerial
          ? p.join(Settings.downloadFolder, name)
          : Settings.downloadFolder,
    );

    if (!await directory.exists()) {
      await directory.create();
    }

    var taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory.path,
      showNotification: true,
      openFileFromNotification: true,
      fileName: '$fileName.mp4',
    );

    Hive.box('download').put(
      'download-$taskId',
      jsonEncode({
        'name': name,
        'episode': episode,
        'isSerial': isSerial,
        'quality': quality,
      }),
    );

    await reloadTasks();
  }

  static _initDownloader() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port?.close();
    _port = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      var item = downloadMap[id];
      if (item != null) {
        item
          ..status = status
          ..progress = progress
          ..update();
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final SendPort send = IsolateNameServer.lookupPortByName(
      'downloader_send_port',
    );
    send.send([id, status, progress]);
  }
}

class DownloadItem {
  BehaviorSubject _controller = BehaviorSubject();
  BehaviorSubject get updateController => _controller;

  final DownloadTask task;
  final DateTime timeCreated;
  final bool isSerial;
  final String name;
  final String episode;
  final String quality;
  DownloadTaskStatus status;
  int progress;

  DownloadItem({
    this.task,
    this.name,
    this.episode = "",
    this.isSerial = true,
    this.quality = "?",
  })  : timeCreated = DateTime.fromMicrosecondsSinceEpoch(
          task.timeCreated * 1000,
        ),
        status = task.status,
        progress = task.progress {
    DownloadManager.downloadMap[task.taskId] = this;
  }

  void update() {
    print('$task.filename: $progress%');
    _controller.add(null);
  }
}
