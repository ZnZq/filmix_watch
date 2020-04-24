import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/managers/media_manager.dart';
import 'package:filmix_watch/filmix/media/episode.dart';
import 'package:filmix_watch/managers/post_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class EpisodeTile extends StatefulWidget {
  final Episode episode;
  final MediaPost post;

  EpisodeTile(this.episode, {@required this.post});

  @override
  _EpisodeTileState createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.episode.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(
              Icons.remove_red_eye,
              color: MediaManager.getView(widget.post.id, widget.episode.id)
                  ? Colors.white
                  : Colors.white30,
            ),
            onPressed: () {
              PostManager.saveIfNotExist(widget.post);
              MediaManager.setView(
                widget.post.id,
                widget.episode,
                !MediaManager.getView(widget.post.id, widget.episode.id),
                saveToHistory: true,
              );
              setState(() {});
            },
          ),
          _buildPopupMenu(
            text: 'Play',
            icon: Icon(
              Icons.play_arrow,
              color: Colors.green,
            ),
            onSelected: (link) async {
              if (await canLaunch(link)) {
                PostManager.saveIfNotExist(widget.post);
                MediaManager.setView(
                  widget.post.id,
                  widget.episode,
                  true,
                  saveToHistory: true,
                );
                setState(() {});
                await launch(link);
              }
            },
          ),
          _buildPopupMenu(
            text: 'Copy',
            icon: Icon(Icons.content_copy),
            onSelected: (link) async {
              await Clipboard.setData(ClipboardData(text: link));
              Fluttertoast.showToast(msg: 'Скопировано');
            },
          ),
        ],
      ),
    );
  }

  PopupMenuButton<String> _buildPopupMenu({
    String text,
    Widget icon,
    Function(String) onSelected,
  }) {
    return PopupMenuButton(
      padding: EdgeInsets.all(0),
      icon: icon,
      itemBuilder: (context) => [
        for (var quality in widget.episode.qualities)
          PopupMenuItem(
            value: quality.url,
            child: FutureBuilder(
              future: quality.getSize(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('$text ${quality.quality} (${snapshot.data})');
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$text ${quality.quality}'),
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
          )
      ],
      onSelected: onSelected,
    );
  }
}
