import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/managers/history_manager.dart';
import 'package:filmix_watch/tiles/poster_tile.dart';
import 'package:flutter/material.dart';

class HistoryPostTile extends StatelessWidget {
  final MediaPost post;
  final List<HistoryItem> historyItems;
  final String hero;

  HistoryPostTile({
    this.post,
    this.historyItems,
    this.hero,
  });

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      child: Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: Colors.white54, spreadRadius: .5),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PosterTile(
              post: post,
              hero: hero,
              imageHeight: 128,
              imageWidth: 88,
              showAdded: false,
              showQuality: false,
              showTime: false,
              showLike: false,
            ),
            // SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.name,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                    Text(
                      post.originName,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    ),
                    Text(historyItems.first.title),
                    if (historyItems.length > 1) ...[
                      Icon(Icons.calendar_view_day),
                      Text(historyItems.last.title)
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
