import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/tiles/poster_tile.dart';
import 'package:flutter/material.dart';

class PostInfo extends StatelessWidget {
  final MediaPost post;
  final String hero;

  PostInfo(this.post, this.hero);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PosterTile(
                post: post,
                hero: hero,
                width: 148,
                showAdded: false,
                contextMenu: false,
              ),
              _buildPostInfo(context),
            ],
          ),
          SizedBox(height: 4),
          if (post.description?.isNotEmpty ?? false)
            _buildAttr('Описание: ', post.description, context),
        ],
      ),
    );
  }

  Expanded _buildPostInfo(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (post.originName.isNotEmpty) ...[
              _buildTitle(),
              SizedBox(height: 4),
            ],
            if (post.year?.isNotEmpty ?? false)
              _buildAttr('Год: ', post.year, context),
            if (post.genre?.isNotEmpty ?? false)
              _buildAttr('Жанр: ', post.genre, context),
            if (post.added?.isNotEmpty ?? false)
              _buildAttr(
                'Последняя серия: ',
                post.added,
                context,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Hero(
      tag: '$hero${post.id}originName',
      child: Material(
        color: Colors.transparent,
        child: Text(
          post.originName,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildAttr(String name, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2),
      child: Hero(
        tag: '$hero}${post.id}$name',
        child: material(Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 15),
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

  Widget material(Widget child) {
    return Material(
      color: Colors.transparent,
      child: child,
    );
  }
}
