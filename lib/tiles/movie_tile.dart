import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/media/quality.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieTile extends StatelessWidget {
  final Quality quality;
  final MediaPost mediaPost;

  MovieTile({
    this.quality,
    this.mediaPost,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16, right: 16),
      leading: Container(
        width: 70,
        height: 40,
        alignment: Alignment.center,
        child: Text(quality.quality),
        decoration: BoxDecoration(color: Colors.orange),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.green),
            onPressed: () async {
              if (await canLaunch(quality.url)) await launch(quality.url);
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
    );
  }
}
