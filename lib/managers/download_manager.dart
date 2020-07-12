import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:filmix_watch/settings.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/subjects.dart';

class DownloadManager {
  static Map<String, DownloadItem> downloadMap = {};
  static List<DownloadItem> downloadItems = [];
  static BehaviorSubject _controller = BehaviorSubject();
  static BehaviorSubject get updateController => _controller;

  static ReceivePort _port;

  static init() async {
    // var box = Hive.box('filmix');
    await reloadTasks();

    // var list = jsonDecode(box.get('downloadItems', defaultValue: '[]')) as List;

    // for (var item in list) {
    //   downloadItems.add(DownloadItem.fromJson(item));
    // }

    _initDownloader();
  }

  static Future reloadTasks() async {
    var tasks = await FlutterDownloader.loadTasks();
    downloadItems.clear();
    for (var task in tasks) {
      downloadItems.add(DownloadItem(task));
    }
  }

  static download({String url, String name}) async {
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: Settings.downloadFolder,
      showNotification: true,
      openFileFromNotification: true,
      fileName: name,
    );
    await reloadTasks();

    _controller.add(null);
  }

  // static save() {
  //   var box = Hive.box('filmix');
  //   var items = downloadItems.map((e) => e.toJson()).toList();
  //   box.put('downloadItems', jsonEncode(items));
  // }

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
  final String url;
  final String filename;
  final String savedDir;
  final int timeCreated;
  DownloadTaskStatus status;
  int progress;

  DownloadItem(this.task)
      : url = task.url,
        filename = task.filename,
        savedDir = task.savedDir,
        timeCreated = task.timeCreated,
        status = task.status,
        progress = task.progress {
    DownloadManager.downloadMap[task.taskId] = this;
  }

  void update() {
    print('$filename: $progress%');
    _controller.add(null);
  }

  // final String taskId;
  // final String url;
  // final String name;
  // DownloadTaskStatus status;
  // int progress;

  // DownloadItem._({
  //   this.taskId,
  //   this.url,
  //   this.name,
  //   this.status,
  //   this.progress,
  // });

  // factory DownloadItem({
  //   String taskId,
  //   String url,
  //   String name,
  //   int status,
  //   int progress,
  // }) {
  //   return DownloadManager.downloadMap.putIfAbsent(
  //       taskId,
  //       () => DownloadItem._(
  //             taskId: taskId,
  //             url: url,
  //             name: name,
  //           ))
  //     ..status = DownloadTaskStatus(status)
  //     ..progress = progress;
  // }

  // factory DownloadItem.fromJson(Map<String, dynamic> json) {
  //   return DownloadItem(
  //     taskId: json['taskId'],
  //     url: json['url'],
  //     name: json['name'],
  //     status: json['status'],
  //     progress: json['progress'],
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'taskId': taskId,
  //     'url': url,
  //     'name': name,
  //     'status': status.value,
  //     'progress': progress,
  //   };
  // }
}
