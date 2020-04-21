import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/tiles/poster_tile.dart';
import 'package:flutter/material.dart';

class SearchPostTile extends StatelessWidget {
  final MediaPost post;
  final String hero = 'search';

  SearchPostTile(this.post);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.white54, spreadRadius: .5),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PosterTile(
            post: post,
            hero: hero,
            width: 120,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  _buildOriginalName(context),
                  SizedBox(height: 4),
                  if (post.year.isNotEmpty)
                    _buildAttr('Год: ', post.year, context),
                  if (post.genre.isNotEmpty)
                    _buildAttr('Жанр: ', post.genre, context),
                  if (post.added.isNotEmpty)
                    _buildAttr('Последняя серия: ', post.added, context),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAttr(String name, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2),
      child: Hero(
        tag: '$hero${post.id}$name',
        child: material(Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 12),
            children: [
              TextSpan(text: name),
              TextSpan(
                text: value,
                style:
                    TextStyle(color: Theme.of(context).textTheme.caption.color),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildOriginalName(BuildContext context) {
    return Hero(
      tag: '$hero${post.id}originName',
      child: material(Text(
        post.originName,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(
            fontSize: 12, color: Theme.of(context).textTheme.caption.color),
      )),
    );
  }

  Widget material(Widget child) {
    return Material(
      color: Colors.transparent,
      child: child,
    );
  }

  Widget _buildTitle() {
    return Hero(
      tag: '$hero${post.id}name',
      child: material(Text(
        post.name,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(fontSize: 16),
      )),
    );
  }
}
