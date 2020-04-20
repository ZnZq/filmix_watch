import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final MediaPost post;
  final LatestType latest;

  PostTile(this.post, this.latest);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 275,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [BoxShadow(color: Colors.white54, spreadRadius: .5)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Stack(
              children: [
                _buildPostPoster(),
                _buildPostLike(),
                _buildPostType(),
                _buildPostTime(),
                if (post.type == PostType.serial) _buildPostAdded(),
                // Positioned(
                //   left: 16,
                //   top: 100,
                //   child: Text(
                //     LatestManager.data[latest].indexOf(post).toString(),
                //     style: TextStyle(
                //       fontSize: 24,
                //       color: Colors.white,
                //       backgroundColor: Colors.black,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          _buildPostName()
        ],
      ),
    );
  }

  Expanded _buildPostName() {
    return Expanded(
      child: Container(
        height: 25,
        color: Colors.grey[700],
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Hero(
          tag: '$latest${post.name}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              post.name,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostPoster() {
    return Hero(
      tag: '$latest${post.poster.original}',
      child: CachedNetworkImage(
        imageUrl: post.poster.original,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
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
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 4),
                child: Text(
                  '${post.like}',
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                            color: Colors.black,
                            offset: Offset.zero,
                            blurRadius: 2)
                      ]),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 4),
                child: Text(
                  '${post.dislike}',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                            color: Colors.black,
                            offset: Offset.zero,
                            blurRadius: 2)
                      ]),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: post.like,
                child: Container(height: 4, color: Colors.green),
              ),
              Expanded(
                flex: post.dislike,
                child: Container(height: 4, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Positioned _buildPostType() {
    return Positioned(
      top: 56 - 28.0 * post.type.index,
      child: Container(
        child: Text(post.type == PostType.serial ? 'Сериал' : 'Фильм'),
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 4, top: 4),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.orange[700], spreadRadius: .5)],
        ),
      ),
    );
  }

  Positioned _buildPostTime() {
    return Positioned(
      top: 28 - 28.0 * post.type.index,
      child: Container(
        child: Text(post.date),
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 4, top: 4),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.orange[700], spreadRadius: .5)],
        ),
      ),
    );
  }

  Widget _buildPostAdded() {
    return Positioned(
      top: 0,
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 4, top: 4),
        margin: EdgeInsets.all(4),
        child: Text(post.added.split(' - ').first),
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.orange[700], spreadRadius: .5)],
        ),
      ),
    );
  }
}
