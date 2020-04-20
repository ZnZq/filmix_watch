import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/search_result.dart';
import 'package:flutter/material.dart';

class SearchPostTile extends StatelessWidget {
  final SearchResult post;

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
          Stack(
            children: [
              _buildPostPoster(),
              _buildPostType(),
            ],
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
                  if (post.categories.isNotEmpty)
                    _buildAttr('Жанр: ', post.categories, context),
                  if (post.lastSerie.isNotEmpty)
                    _buildAttr('Последняя серия: ',
                        post.lastSerie.split(' - ').first, context),
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
      child: Text.rich(
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
      ),
    );
  }

  Text _buildOriginalName(BuildContext context) {
    return Text(
      post.originalName,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: TextStyle(
          fontSize: 12, color: Theme.of(context).textTheme.caption.color),
    );
  }

  Widget _buildTitle() {
    return Hero(
      tag: 'search${post.title}',
      child: Material(
        color: Colors.transparent,
        child: Text(
          post.title,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPostPoster() {
    return Hero(
      tag: 'search${post.poster.original}',
      child: CachedNetworkImage(
        imageUrl: post.poster.original,
        width: 100,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
      ),
    );
  }

  Positioned _buildPostType() {
    return Positioned(
      bottom: 0,
      child: Container(
        child: Text(
          post.type == PostType.serial ? 'Сериал' : 'Фильм',
          style: TextStyle(fontSize: 12),
        ),
        padding: EdgeInsets.only(left: 6, right: 6, bottom: 2, top: 2),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.orange[700], spreadRadius: .5)],
        ),
      ),
    );
  }
}
