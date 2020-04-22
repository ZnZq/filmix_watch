import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmix_watch/bloc/favorite_manager.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PosterTile extends StatelessWidget {
  final MediaPost post;
  final String hero;
  final double imageWidth, imageHeight, likeSize;
  final int number;
  final bool showType, showLike, showTime, showAdded, showQuality;
  final bool contextMenu;

  PosterTile({
    @required this.post,
    @required this.hero,
    this.imageWidth,
    this.imageHeight,
    this.number,
    this.likeSize = 12,
    this.showLike = true,
    this.showTime = true,
    this.showType = true,
    this.showAdded = true,
    this.showQuality = true,
    this.contextMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Settings.updateController,
      builder: (_, __) {
        Widget child = Stack(
          children: [
            Container(
              width: imageWidth,
              height: imageHeight,
              child: _buildPostPoster(),
            ),
            _buildInfo(),
            if (Settings.showPostLike && showLike) _buildPostLike(),
          ],
        );

        return contextMenu
            ? GestureDetector(
                child: child,
                onLongPressStart: (details) {
                  final RenderBox referenceBox = context.findRenderObject();
                  var tapPosition =
                      referenceBox.globalToLocal(details.globalPosition);

                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context)
                      .context
                      .findRenderObject() as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(tapPosition, ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero),
                          ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );

                  FavoriteManager.showFavoriteMenu(context, position, post);
                },
              )
            : child;
      },
    );
  }

  Widget _buildInfo() {
    return Positioned(
      top: 4,
      left: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Settings.showPostQuality && showQuality) ...[
            _buildQuality(),
            SizedBox(height: 3),
          ],
          if (Settings.showPostAdded && showAdded && post.added.isNotEmpty) ...[
            _buildPostAdded(),
            SizedBox(height: 3),
          ],
          if (Settings.showPostTime && showTime) ...[
            _buildPostTime(),
            SizedBox(height: 3),
          ],
          if (Settings.showPostType && showType) ...[
            _buildPostType(),
            SizedBox(height: 3),
          ],
          if (Settings.showPostNumber && number != null) _buildNumber(number)
        ],
      ),
    );
  }

  Widget _buildQuality() {
    return heroMaterial(
      heroKey: 'quality',
      child: Container(
        child: Text(post.quality, style: TextStyle(fontSize: 12)),
        padding: EdgeInsets.only(left: 4, right: 4, bottom: 2, top: 2),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.blue[700], spreadRadius: .5)],
        ),
      ),
    );
  }

  Widget heroMaterial({String heroKey, Widget child}) {
    return Hero(
      tag: '$hero${post.id}$heroKey',
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  Widget _buildNumber(int number) {
    return heroMaterial(
      heroKey: 'number',
      child: Container(
        padding: EdgeInsets.only(left: 4, right: 4, top: 2, bottom: 2),
        child: Text(
          '#$number',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.orange[700], spreadRadius: .5)],
        ),
      ),
    );
  }

  Widget _buildPostPoster() {
    return Hero(
      tag: '$hero${post.id}poster',
      child: CachedNetworkImage(
        imageUrl: post.poster.original,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
      ),
    );
  }

  Widget _buildPostLike() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 4),
                child: heroMaterial(
                  heroKey: 'like',
                  child: Text(
                    '${post.like}',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: likeSize,
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              offset: Offset.zero,
                              blurRadius: 2)
                        ]),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 4),
                child: heroMaterial(
                  heroKey: 'dislike',
                  child: Text(
                    '${post.dislike}',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w900,
                        fontSize: likeSize,
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              offset: Offset.zero,
                              blurRadius: 2)
                        ]),
                  ),
                ),
              ),
            ],
          ),
          heroMaterial(
            heroKey: 'likeBar',
            child: Row(
              children: [
                Expanded(
                  flex: max(1, post.like),
                  child: Container(height: 2, color: Colors.green),
                ),
                Expanded(
                  flex: max(1, post.dislike),
                  child: Container(height: 2, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostAdded() {
    return heroMaterial(
      heroKey: 'added',
      child: Container(
        padding: EdgeInsets.only(left: 4, right: 4, bottom: 2, top: 2),
        child:
            Text(post.added.split(' - ').first, style: TextStyle(fontSize: 12)),
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.orange[700], spreadRadius: .5)],
        ),
      ),
    );
  }

  Widget _buildPostTime() {
    return heroMaterial(
      heroKey: 'date',
      child: Container(
        child: Text(post.date, style: TextStyle(fontSize: 12)),
        padding: EdgeInsets.only(left: 4, right: 4, bottom: 2, top: 2),
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.orange[700], spreadRadius: .5)],
        ),
      ),
    );
  }

  Widget _buildPostType() {
    return heroMaterial(
      heroKey: 'type',
      child: Container(
        child: Text(
          post.type == PostType.serial ? 'Сериал' : 'Фильм',
          style: TextStyle(fontSize: 12),
        ),
        padding: EdgeInsets.only(left: 6, right: 6, bottom: 2, top: 2),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.orange[700], spreadRadius: .5)],
        ),
      ),
    );
  }
}
