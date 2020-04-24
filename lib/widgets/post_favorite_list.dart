import 'package:filmix_watch/managers/favorite_manager.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/tiles/row_post_tile.dart';
import 'package:flutter/material.dart';

class PostFavoriteList extends StatefulWidget {
  final FavoriteTab tab;

  PostFavoriteList(this.tab);

  @override
  _PostFavoriteListState createState() => _PostFavoriteListState();
}

class _PostFavoriteListState extends State<PostFavoriteList> with AutomaticKeepAliveClientMixin<PostFavoriteList> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FavoriteManager.updateController,
      builder: (context, snapshot) {
        var posts = FavoriteManager.getFavoriteTabPosts(widget.tab);

        if (posts.isEmpty) {
          return Center(child: Text('Список пуст'),);
        }

        return ReorderableListView(
          padding: EdgeInsets.all(4),
          onReorder: (int oldIndex, int newIndex) {
            if (newIndex >= FavoriteManager.posts[widget.tab].length) {
              newIndex = FavoriteManager.posts[widget.tab].length - 1;
            }

            if (oldIndex == newIndex) {
              return;
            }

            int item = FavoriteManager.posts[widget.tab].removeAt(oldIndex);
            FavoriteManager.posts[widget.tab].insert(newIndex, item);
            FavoriteManager.save();
          },
          children: [
            for (var post in posts)
              GestureDetector(
                key: ValueKey(post.id),
                child: RowPostTile(
                  post,
                  hero: widget.tab.toString(),
                  margin: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width - 16,
                ),
                onTap: () {
                  Navigator.pushNamed(context, PostPage.route, arguments: {
                    'hero': widget.tab.toString(),
                    'post': post,
                  });
                },
              ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
