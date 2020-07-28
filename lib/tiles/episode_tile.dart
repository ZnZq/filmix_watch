import 'package:filmix_watch/filmix/media/quality.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/managers/download_manager.dart';
import 'package:filmix_watch/managers/media_manager.dart';
import 'package:filmix_watch/filmix/media/episode.dart';
import 'package:filmix_watch/managers/post_manager.dart';
import 'package:filmix_watch/widgets/episode_quality_item.dart';
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
          _buildViewButton(),
          PopupMenuButton(
            itemBuilder: (_) => [
              for (var quality in widget.episode.qualities)
                PopupMenuItem(
                  value: quality,
                  child: EpisodeQualityItem(
                    episode: widget.episode,
                    post: widget.post,
                    quality: quality,
                    view: _view,
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  IconButton _buildViewButton() {
    return IconButton(
      padding: EdgeInsets.all(0),
      icon: Icon(
        Icons.remove_red_eye,
        color: MediaManager.getView(widget.post.id, widget.episode.id)
            ? Colors.white
            : Colors.white30,
      ),
      onPressed: () {
        _view(!MediaManager.getView(widget.post.id, widget.episode.id));
      },
    );
  }

  void _view(bool view) {
    PostManager.saveIfNotExist(widget.post);
    MediaManager.setView(
      widget.post.id,
      widget.episode.id,
      view,
      saveToHistory: true,
      episodeTitle: widget.episode.title,
    );
    setState(() {});
  }

  // PopupMenuButton<Quality> _buildPopupMenu({
  //   String text,
  //   Widget icon,
  //   Function(Quality) onSelected,
  // }) {
  //   return PopupMenuButton(
  //     padding: EdgeInsets.all(0),
  //     icon: icon,
  //     itemBuilder: (context) => [
  //       for (var quality in widget.episode.qualities)
  //         PopupMenuItem(
  //           value: quality,
  //           child: FutureBuilder(
  //             future: quality.getSize(),
  //             builder: (context, snapshot) {
  //               if (snapshot.hasData) {
  //                 return Text('$text ${quality.quality} (${snapshot.data})');
  //               }

  //               return Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text('$text ${quality.quality}'),
  //                   SizedBox(width: 8),
  //                   SizedBox(
  //                     width: 16,
  //                     height: 16,
  //                     child: CircularProgressIndicator(),
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         )
  //     ],
  //     onSelected: onSelected,
  //   );
  // }
}
