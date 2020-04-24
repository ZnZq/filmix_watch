import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/media/quality.dart';
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
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16, right: 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
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
          ),
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.green),
            onPressed: () async {
              if (await canLaunch(quality.url)) {
                _view(true);
                launch(quality.url);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: quality.url));
              Fluttertoast.showToast(msg: 'Скопировано');
            },
          ),
        ],
      ),
      title: Text(
        mediaPost.name,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      subtitle: FutureBuilder(
        future: quality.getSize(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text('${quality.quality} (${snapshot.data})');
          }

          return Row(
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
          );
        },
      ),
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
