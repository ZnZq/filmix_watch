import 'package:filmix_watch/filmix/media/translation.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieTile extends StatelessWidget {
  final MovieTranslation movieTranslation;
  final MediaPost mediaPost;

  MovieTile({
    this.movieTranslation,
    this.mediaPost,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        for (var quality
            in movieTranslation.qualities.entries.toList().reversed) ...[
          ListTile(
            contentPadding: EdgeInsets.only(left: 16, right: 16),
            leading: Container(
              width: 70,
              height: 40,
              alignment: Alignment.center,
              child: Text(quality.key),
              // padding: EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
              decoration: BoxDecoration(color: Colors.orange),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: () async {
                    if (await canLaunch(quality.value)) await launch(quality.value);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.content_copy),
                  onPressed: () async{
                    await Clipboard.setData(ClipboardData(text: quality.value));
                    Fluttertoast.showToast(msg: 'Скопировано');
                  },
                ),
              ],
            ),
            title: Text(mediaPost.name),
          ),
          Divider(height: 0)
        ]
      ],
    );
  }
}
