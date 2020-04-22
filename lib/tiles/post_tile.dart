import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/tiles/poster_tile.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final MediaPost post;
  final String hero;
  final int number;

  final bool showAdded, showTime;

  PostTile(
    this.post,
    this.hero, {
    this.number,
    this.showAdded = true,
    this.showTime = true,
  });

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
            child: PosterTile(
              post: post,
              hero: hero,
              imageHeight: 250,
              imageWidth: double.infinity,
              number: number,
              showAdded: showAdded,
              showTime: showTime,
              likeSize: 16,
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
          tag: '$hero${post.id}name',
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
}
