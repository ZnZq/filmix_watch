import 'dart:async';
import 'dart:math';

import 'package:filmix_watch/bloc/favorite_manager.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/settings.dart';
import 'package:filmix_watch/tiles/post_tile.dart';
import 'package:filmix_watch/tiles/row_post_tile.dart';
import 'package:filmix_watch/widgets/post_grid_view.dart';
import 'package:flutter/material.dart';

class PostFavoriteList extends StatefulWidget {
  final FavoriteTab tab;

  PostFavoriteList(this.tab);

  @override
  _PostFavoriteListState createState() => _PostFavoriteListState();
}

class _PostFavoriteListState extends State<PostFavoriteList> {
  // var count = 0;
  // var lastCount = 0;
  // var lastFirst = 0;
  // var h = 275 + 8.0;
  // Timer timer;
  // var isScrool = true;

  // ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    // scrollController = ScrollController();
    // scrollController.addListener(scrollListener);
  }

  // scrollListener() {
  //   isScrool = true;
  //   timer?.cancel();
  //   timer = Timer(Duration(milliseconds: 500), normalize);
  // }

  // normalize() {
  //   if (Settings.smartScroll &&
  //       scrollController.positions.isNotEmpty &&
  //       lastCount == 2) {
  //     var indexLast = (scrollController.position.pixels * lastCount / h).ceil();
  //     int firstLast = (indexLast - indexLast.floor() % lastCount);
  //     var row = (firstLast / count);

  //     var newPos = max(0.0, row * h);
  //     scrollController.animateTo(
  //       newPos,
  //       duration: Duration(milliseconds: 250),
  //       curve: Curves.easeInOut,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FavoriteManager.updateController,
      builder: (context, snapshot) {
        var posts = FavoriteManager.getFavoriteTabPosts(widget.tab);

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
