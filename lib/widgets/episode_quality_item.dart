import 'package:filmix_watch/filmix/media/episode.dart';
import 'package:filmix_watch/filmix/media/quality.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/managers/download_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class EpisodeQualityItem extends StatefulWidget {
  final Quality quality;
  final Episode episode;
  final MediaPost post;
  final Function view;

  EpisodeQualityItem({
    this.quality,
    this.episode,
    this.post,
    this.view,
  });

  @override
  _EpisodeQualityItemState createState() => _EpisodeQualityItemState();
}

class _EpisodeQualityItemState extends State<EpisodeQualityItem> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.quality.getSize(),
      initialData: null,
      builder: (context, snapshot) {
        if (widget.quality.size > 0) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(),
              _buildEpisodeQuality(widget.quality, snapshot, context),
              Spacer(),
              _buildPlayButton(widget.quality),
              _buildCopyButton(widget.quality),
              _buildDownloadButton(widget.quality),
              _buildRefreshButton(widget.quality),
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.quality.quality}'),
            SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEpisodeQuality(
    Quality quality,
    AsyncSnapshot snapshot,
    BuildContext context,
  ) {
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
          widget.view(true);
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

  Widget _buildRefreshButton(Quality quality) {
    return IconButton(
      constraints: BoxConstraints(
        minWidth: 0,
        minHeight: 0,
      ),
      icon: Icon(
        Icons.refresh,
        color: Colors.white,
      ),
      onPressed: () async {
        setState(() {
          quality.clearSize();
        });
      },
    );
  }
}
