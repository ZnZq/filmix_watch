import 'dart:async';
import 'dart:math';

import 'package:filmix_watch/bloc/latest_manager.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/tiles/post_tile.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PostGrid extends StatefulWidget {
  final LatestType latestType;
  final Map<int, GlobalKey> keys = {};

  PostGrid(this.latestType);

  @override
  PostGridState createState() => PostGridState();
}

class PostGridState extends State<PostGrid>
    with AutomaticKeepAliveClientMixin<PostGrid> {
  RefreshController _refreshController;

  ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(
      initialRefresh: LatestManager.data[widget.latestType].isEmpty,
    );

    scrollController = ScrollController();

    scrollController.addListener(scrollListener);
  }

  Timer timer;
  double h = (275 + 8.0);
  bool isScrool = false;

  scrollListener() {
    if (isScrool) return;
    timer?.cancel();
    timer = Timer(Duration(milliseconds: 500), normalize);
  }

  normalize() {
    isScrool = true;
    print('normalize ${DateTime.now()}');
    if (scrollController.positions.isNotEmpty) {
      var indexLast = (scrollController.position.pixels * lastCount / h).ceil();
      int firstLast = (indexLast - indexLast.floor() % lastCount);
      var row = (firstLast / count);

      var newPos = max(0.0, row * h);
      scrollController.animateTo(
        newPos,
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
    isScrool = false;
  }

  void _onRefresh() {
    LatestManager.refreshData(widget.latestType)
        .then((_) => _refreshController.refreshCompleted());
  }

  void _onLoading() {
    LatestManager.loadData(widget.latestType)
        .then((_) => _refreshController.loadComplete());
  }

  var count = 0;
  var lastCount = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        count = constraints.maxWidth > constraints.maxHeight ? 3 : 2;

        if (scrollController.positions.isNotEmpty) {
          // print(
          //     '${widget.latestType} - pos: ${scrollController.position.pixels}');

          // var indexLast = (scrollController.position.pixels * lastCount / h);
          // // print('${widget.latestType} - indexLast: $indexLast');

          // double firstLast = indexLast - indexLast.floor() % lastCount;
          // print('${widget.latestType} - firstLast: $firstLast');

          // var row = (firstLast / count);
          // print('${widget.latestType} - row: $row');

          // var index = (scrollController.position.pixels * count / h);
          // print('${widget.latestType} - index: $index');

          //  var row = index ~/ count;
          // print('${widget.latestType} - row: $row');

          //   double first = index - index % lastCount;
          //   print('${widget.latestType} - first: $first');

          // var indexLast =
          //     (scrollController.position.pixels * lastCount / h).ceil();
          // int firstLast = (indexLast - indexLast.floor() % lastCount);
          // var row = (indexLast / count);

          // print('${widget.latestType} - row: $row');

          // if (lastCount != count) {
          //   var newPos = max(0.0, row * h);
          //   // print('last: ${scrollController.position.pixels}, new: $newPos');
          //   scrollController.animateTo(
          //     newPos,
          //     duration: Duration(milliseconds: 500),
          //     curve: Curves.fastOutSlowIn,
          //   );
          // }
        }

        lastCount = count;

        return StreamBuilder<LatestState>(
          stream: LatestManager.streams[widget.latestType],
          builder: (BuildContext context, AsyncSnapshot<LatestState> snapshot) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: GridView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(8),
                itemCount: LatestManager.data[widget.latestType].length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio:
                      ((constraints.maxWidth - (count + 1) * 8) / count) /
                          (h - 8),
                ),
                itemBuilder: (BuildContext context, int index) {
                  var e = LatestManager.data[widget.latestType][index];
                  return GestureDetector(
                    child: PostTile(e, widget.latestType),
                    onTap: () {
                      Navigator.pushNamed(context, PostPage.route,
                          arguments: {'hero': widget.latestType, 'post': e});
                    },
                  );
                },
              ),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.loading) {
                    body = CircularProgressIndicator();
                  }
                  return Container(
                    padding: EdgeInsets.only(top: 12, bottom: 16),
                    child: Center(child: body),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
