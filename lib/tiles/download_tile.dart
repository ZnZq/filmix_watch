import 'dart:io';

import 'package:filmix_watch/managers/download_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';

class DownloadTile extends StatelessWidget {
  final DownloadItem item;

  DownloadTile(this.item);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: item.updateController,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return ListTile(
          leading: _buildLeading(),
          title: Text(item.task.filename),
          onTap: item.status == DownloadTaskStatus.complete
              ? () async {
                  var filePath = p.join(item.savedDir, item.filename);
                  var file = File(filePath);
                  if (await file.exists()) {
                    OpenFile.open(filePath);
                  } else {
                    Fluttertoast.showToast(msg: 'Файл не найден!');
                  }
                }
              : null,
        );
      },
    );
  }

  Widget _buildLeading() {
    return Stack(
      children: [
        Positioned.fill(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: item.progress / 100,
            backgroundColor: Colors.grey[800],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 28,
            height: 28,
            child: _buildStatusIcon(),
          ),
        )
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (item.status.value) {
      case 0:
        return Icon(Icons.error_outline); // undefined
      case 1:
        return Icon(Icons.timelapse); // enqueued
      case 2:
        return Icon(Icons.cloud_download); // running
      case 3:
        return Icon(Icons.check); // complete
      case 4:
        return Icon(Icons.error); // failed
      case 5:
        return Icon(Icons.cancel); // canceled
      case 6:
        return Icon(Icons.pause); // paused
    }

    return Icon(Icons.pause);
  }
}
