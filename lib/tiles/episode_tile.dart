import 'package:filmix_watch/filmix/media/episode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class EpisodeTile extends StatelessWidget {
  final Episode episode;

  EpisodeTile(this.episode);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(episode.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPopupMenu(
            text: 'Play',
            icon: Icon(
              Icons.play_arrow,
              color: Colors.green,
            ),
            onSelected: (link) async {
              if (await canLaunch(link)) await launch(link);
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
      icon: icon,
      itemBuilder: (context) => [
        for (var quality
            in episode.qualities.keys.toList()..sort((a, b) => b.compareTo(a)))
          PopupMenuItem(
            value: episode.qualities[quality],
            child: Text('$text $quality'),
          )
      ],
      onSelected: onSelected,
    );
  }
}
