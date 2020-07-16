import 'package:filmix_watch/filmix/media/quality.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/managers/download_manager.dart';
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
          _buildViewButton(),
          PopupMenuButton(
            itemBuilder: (_) => [
              for (var quality in widget.episode.qualities)
                PopupMenuItem(
                  value: quality,
                  child: FutureBuilder(
                    future: quality.getSize(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Spacer(),
                            _buildEpisodeQuality(quality, snapshot, context),
                            Spacer(),
                            _buildPlayButton(quality),
                            _buildCopyButton(quality),
                            _buildDownloadButton(quality),
                          ],
                        );
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${quality.quality}'),
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

  Column _buildEpisodeQuality(
      Quality quality, AsyncSnapshot snapshot, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(quality.quality),
        Text(
          '(${snapshot.data})',
          style: TextStyle(
            color: Theme.of(context).textTheme.caption.color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(quality) {
    return IconButton(
      constraints: BoxConstraints(
        minWidth: 0,
        minHeight: 0,
      ),
      icon: Icon(
        Icons.play_arrow,
        color: Colors.green,
      ),
      onPressed: () async {
        if (await canLaunch(quality.url)) {
          _view(true);
          launch(quality.url);
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildCopyButton(quality) {
    return IconButton(
      constraints: BoxConstraints(
        minWidth: 0,
        minHeight: 0,
      ),
      icon: Icon(
        Icons.content_copy,
        color: Colors.blue,
      ),
      onPressed: () async {
        await Clipboard.setData(
          ClipboardData(text: quality.url),
        );
        Fluttertoast.showToast(msg: 'Скопировано');
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDownloadButton(Quality quality) {
    return IconButton(
      constraints: BoxConstraints(
        minWidth: 0,
        minHeight: 0,
      ),
      icon: Opacity(
        opacity: DownloadManager.hasInDownloads(quality.url) ? .5 : 1,
        child: Icon(
          Icons.file_download,
          color: Colors.orange,
        ),
      ),
      onPressed: () async {
        if (DownloadManager.hasInDownloads(quality.url)) {
          Fluttertoast.showToast(
            msg: 'Данный материал уже находиться в списке загрузок',
          );
          return;
        }

        await DownloadManager.download(
          url: quality.url,
          name: widget.post.name,
          episode: widget.episode.originalId,
          quality: quality.quality,
        );
        Fluttertoast.showToast(
          msg: 'Загрузка: ${widget.post.name} ${widget.episode.originalId}',
        );
        Navigator.pop(context);
      },
    );
  }

  void _view(bool view) {
    PostManager.saveIfNotExist(widget.post);
    MediaManager.setView(widget.post.id, widget.episode.id, view,
        saveToHistory: true, episodeTitle: widget.episode.title);
    setState(() {});
  }

  PopupMenuButton<Quality> _buildPopupMenu({
    String text,
    Widget icon,
    Function(Quality) onSelected,
  }) {
    return PopupMenuButton(
      padding: EdgeInsets.all(0),
      icon: icon,
      itemBuilder: (context) => [
        for (var quality in widget.episode.qualities)
          PopupMenuItem(
            value: quality,
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
