import 'package:filmix_watch/bloc/media_manager.dart';
import 'package:filmix_watch/filmix/media/episode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class EpisodeTile extends StatefulWidget {
  final Episode episode;
  final int postId;

  EpisodeTile(this.episode, {@required this.postId});

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
              color: MediaManager.getView(widget.postId, widget.episode.id)
                  ? Colors.white
                  : Colors.white30,
            ),
            onPressed: () {
              MediaManager.setView(
                widget.postId,
                widget.episode.id,
                !MediaManager.getView(widget.postId, widget.episode.id),
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
                MediaManager.setView(widget.postId, widget.episode.id, true);
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
            child: Text('$text ${quality.quality}'),
          )
      ],
      onSelected: onSelected,
    );
  }
}
