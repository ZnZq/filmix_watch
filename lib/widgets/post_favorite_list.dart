import 'package:filmix_watch/bloc/favorite_manager.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/tiles/row_post_tile.dart';
import 'package:flutter/material.dart';

class PostFavoriteList extends StatefulWidget {
  final FavoriteTab tab;
  final PostType type;

  PostFavoriteList(this.tab, this.type);

  @override
  _PostFavoriteListState createState() => _PostFavoriteListState();
}

class _PostFavoriteListState extends State<PostFavoriteList> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FavoriteManager.updateController,
      builder: (context, snapshot) {
        var posts = FavoriteManager.getFavoriteTabPosts(widget.tab, widget.type);

        if (posts.isEmpty) {
          return Center(child: Text('Список пуст'),);
        }

        return ReorderableListView(
          padding: EdgeInsets.all(4),
          onReorder: (int oldIndex, int newIndex) {
            if (newIndex >= FavoriteManager.posts[widget.tab][widget.type].length) {
              newIndex = FavoriteManager.posts[widget.tab][widget.type].length - 1;
            }

            if (oldIndex == newIndex) {
              return;
            }

            int item = FavoriteManager.posts[widget.tab][widget.type].removeAt(oldIndex);
            FavoriteManager.posts[widget.tab][widget.type].insert(newIndex, item);
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
    // return LayoutBuilder(
    //   builder: (BuildContext context, BoxConstraints constraints) {
    //     count = (constraints.maxWidth / 175).floor();

    //     if (scrollController.positions.isNotEmpty) {
    //       normalizeRotationPosition();
    //     }

    //     lastCount = count;

    //     return StreamBuilder(
    //       stream: FavoriteManager.updateController,
    //       builder: (context, snapshot) {
    //         var posts = FavoriteManager.getFavoriteTabPosts(widget.tab);

    //         return PostGridView(
    //           inRowCount: count,
    //           scrollController: scrollController,
    //           width: constraints.maxWidth,
    //           itemCount: posts.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             var e = posts[index];
    //             return PostTile(
    //               e,
    //               widget.tab.toString(),
    //               showAdded: false,
    //               showTime: false,
    //             );
    //           },
    //         );
    //       },
    //     );
    //   },
    // );
  }

  // void normalizeRotationPosition() {
  //   var old = calc(scrollController.position.pixels, lastCount, h);

  //   var oldFirst = old[1];

  //   var newRow =
  //       ((isScrool ? (lastFirst = oldFirst) : lastFirst) / count).floor();

  //   if (lastCount != count) {
  //     var newPos = max(0.0, newRow * h);
  //     scrollController
  //         .animateTo(
  //       newPos,
  //       duration: Duration(milliseconds: 500),
  //       curve: Curves.fastOutSlowIn,
  //     )
  //         .then((value) {
  //       isScrool = false;
  //     });
  //   }
  // }

  // List<int> calc(double scroll, int width, double height) {
  //   var index = (scroll * width / height);

  //   var row = index / width;

  //   if (row - row.floor() > 0.8)
  //     row = row.roundToDouble();
  //   else
  //     row = row.floorToDouble();

  //   var first = row * width;

  //   return [row.toInt(), first.toInt()];
  // }
}
