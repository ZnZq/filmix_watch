import 'package:filmix_watch/bloc/latest_manager.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/tiles/poster_tile.dart';
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
            child: PosterTile(
              post: post,
              hero: latest.toString(),
              imageHeight: 250,
              width: double.infinity,
              number: LatestManager.data[latest].indexOf(post) + 1,
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
          tag: '$latest${post.id}name',
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
