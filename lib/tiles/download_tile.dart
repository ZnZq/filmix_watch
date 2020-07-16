import 'package:filmix_watch/managers/download_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
          title: Text('${item.name}${item.isSerial ? ' ' + item.episode : ''}',
              overflow: TextOverflow.fade),
          subtitle: Text(item.task.savedDir, overflow: TextOverflow.fade),
          trailing: PopupMenuButton(
            itemBuilder: _buildPopupItems,
            onSelected: (value) => _onSelectPopupItem(value, context),
          ),
        );
      },
    );
  }

  _onSelectPopupItem(value, context) async {
    switch (value) {
      case 'Play':
        {
          var isOpen = await DownloadManager.open(item);
          if (!isOpen) {
            Fluttertoast.showToast(
              msg: 'Ваше устройство не может открыть данный файл',
            );
          }
          break;
        }
      case 'Pause':
        {
          await DownloadManager.pause(item);
          break;
        }
      case 'Resume':
        {
          await DownloadManager.resume(item);
          break;
        }
      case 'Cancel':
        {
          await DownloadManager.cancel(item);
          break;
        }
      case 'Retry':
        {
          await DownloadManager.retry(item);
          break;
        }
      case 'Delete':
        {
          var remove = await openRemoveDialog(context);
          if (remove == null) return;
          DownloadManager.remove(item, remove);
          break;
        }
    }
  }

  List<PopupMenuEntry> _buildPopupItems(context) => <PopupMenuEntry>[
        if (item.status == DownloadTaskStatus.complete) ...[
          PopupMenuItem(
            value: 'Play',
            child: Text('Смотреть'),
          )
        ],
        if (item.status == DownloadTaskStatus.running) ...[
          PopupMenuItem(
            value: 'Pause',
            child: Text('Пауза'),
          )
        ],
        if (item.status == DownloadTaskStatus.paused) ...[
          PopupMenuItem(
            value: 'Resume',
            child: Text('Возобновить'),
          )
        ],
        if ([
          DownloadTaskStatus.paused,
          DownloadTaskStatus.running,
        ].contains(item.status)) ...[
          PopupMenuItem(
            value: 'Cancel',
            child: Text('Отменить'),
          )
        ],
        if (item.status == DownloadTaskStatus.failed) ...[
          PopupMenuItem(
            value: 'Retry',
            child: Text('Повторить'),
          )
        ],
        PopupMenuDivider(height: 0),
        PopupMenuItem(
          value: 'Delete',
          child: Text('Удалить'),
        )
      ];

  Future<bool> openRemoveDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удаление загрузки'),
        content: Text(
          'Вы действительно хотите удалить "${item.task.filename}"?',
        ),
        actions: [
          FlatButton(
            child: Text('Удалить запись с файлом'),
            textColor: Colors.red,
            onPressed: () => Navigator.pop(context, true),
          ),
          FlatButton(
            child: Text('Удалить запись'),
            textColor: Colors.red,
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text('Отмена'),
            textColor: Colors.blue,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
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
