import 'package:filmix_watch/managers/download_manager.dart';
import 'package:filmix_watch/tiles/download_tile.dart';
import 'package:flutter/material.dart';

class DownloadPage extends StatefulWidget {
  static final String route = '/download';
  static final String title = 'Загрузки';

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DownloadPage.title),
      ),
      body: StreamBuilder(
        stream: DownloadManager.updateController,
        builder: (context, snapshot) {
          if (DownloadManager.downloadItems.isEmpty) {
            return Center(child: Text('Список пуст'));
          }

          return ListView.separated(
            itemCount: DownloadManager.downloadItems.length,
            itemBuilder: (context, index) {
              return DownloadTile(DownloadManager.downloadItems[index]);
            },
            separatorBuilder: (_, __) => Divider(height: 0),
          );
        },
      ),
    );
  }
}
