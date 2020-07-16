import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/media/quality.dart';
import 'package:filmix_watch/managers/download_manager.dart';
import 'package:filmix_watch/managers/media_manager.dart';
import 'package:filmix_watch/managers/post_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieTile extends StatelessWidget {
  final Quality quality;
  final MediaPost mediaPost;
  final Function updateUi;

  MovieTile({
    this.quality,
    this.mediaPost,
    this.updateUi,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: quality.getSize(),
      builder: (context, snapshot) {
        return ListTile(
          contentPadding: EdgeInsets.only(left: 16, right: 16),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewButton(),
              // IconButton(
              //   icon: Icon(Icons.play_arrow, color: Colors.green),
              //   onPressed: () async {
              //     if (await canLaunch(quality.url)) {
              //       _view(true);
              //       launch(quality.url);
              //     }
              //   },
              // ),
              // IconButton(
              //   icon: Icon(Icons.content_copy),
              //   onPressed: () async {
              //     await Clipboard.setData(ClipboardData(text: quality.url));
              //     Fluttertoast.showToast(msg: 'Скопировано');
              //   },
              // ),
              if (snapshot.hasData)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    _buildPopupItem(
                      value: 'Play',
                      icon: Icon(Icons.play_arrow, color: Colors.green),
                    ),
                    _buildPopupItem(
                      value: 'Copy',
                      icon: Icon(Icons.content_copy),
                    ),
                    _buildPopupItem(
                      value: 'Download',
                      icon: Opacity(
                        opacity: DownloadManager.hasInDownloads(quality.url)
                            ? .5
                            : 1,
                        child: Icon(
                          Icons.file_download,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'Play':
                        {
                          if (await canLaunch(quality.url)) {
                            _view(true);
                            launch(quality.url);
                          }
                          break;
                        }
                      case 'Copy':
                        {
                          await Clipboard.setData(
                            ClipboardData(text: quality.url),
                          );
                          Fluttertoast.showToast(msg: 'Скопировано');
                          break;
                        }
                      case 'Download':
                        {
                          if (DownloadManager.hasInDownloads(quality.url)) {
                            Fluttertoast.showToast(
                              msg:
                                  'Данный материал уже находиться в списке загрузок',
                            );
                            return;
                          }
                          await DownloadManager.download(
                            url: quality.url,
                            name: mediaPost.name,
                            isSerial: false,
                          );
                          Fluttertoast.showToast(
                            msg: 'Загрузка: ${mediaPost.name}',
                          );
                          break;
                        }
                    }
                  },
                )
              else
                CircularProgressIndicator()
            ],
          ),
          title: Text(
            mediaPost.name,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          subtitle: snapshot.hasData
              ? Text('${quality.quality} (${snapshot.data})')
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(quality.quality),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildPopupItem({String value, Widget icon}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon,
          SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  IconButton _buildViewButton() {
    return IconButton(
      padding: EdgeInsets.all(0),
      icon: Icon(
        Icons.remove_red_eye,
        color: MediaManager.getView(mediaPost.id, 0)
            ? Colors.white
            : Colors.white30,
      ),
      onPressed: () {
        _view(!MediaManager.getView(mediaPost.id, 0));
      },
    );
  }

  void _view(bool view) {
    PostManager.saveIfNotExist(mediaPost);
    MediaManager.setView(
      mediaPost.id,
      0,
      view,
      saveToHistory: true,
    );
    updateUi(() {});
  }
}
