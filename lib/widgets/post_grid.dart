import 'dart:async';
import 'dart:math';

import 'package:filmix_watch/bloc/latest_manager.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/settings.dart';
import 'package:filmix_watch/tiles/post_tile.dart';
import 'package:filmix_watch/widgets/post_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PostGrid extends StatefulWidget {
  final LatestType latestType;

  PostGrid(this.latestType);

  @override
  PostGridState createState() => PostGridState();
}

class PostGridState extends State<PostGrid> with AutomaticKeepAliveClientMixin<PostGrid> {
  var count = 0;
  var lastCount = 0;
  var lastFirst = 0;
  var h = 275 + 8.0;
  Timer timer;
  var isScrool = true;

  RefreshController _refreshController;
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    _refreshController = RefreshController(
      initialRefresh: LatestManager.data[widget.latestType].isEmpty,
    );

    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
  }

  scrollListener() {
    isScrool = true;
    timer?.cancel();
    timer = Timer(Duration(milliseconds: 500), normalize);
  }

  normalize() {
    if (Settings.smartScroll &&
        scrollController.positions.isNotEmpty &&
        lastCount == 2) {
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
  }

  void _onRefresh() {
    LatestManager.refreshData(widget.latestType)
        .then((_) => _refreshController.refreshCompleted());
  }

  void _onLoading() {
    LatestManager.loadData(widget.latestType)
        .then((_) => _refreshController.loadComplete());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        count = (constraints.maxWidth / 175).floor();

        if (scrollController.positions.isNotEmpty) {
          normalizeRotationPosition();
        }

        lastCount = count;

        return StreamBuilder<LatestState>(
          stream: LatestManager.streams[widget.latestType],
          builder: (BuildContext context, AsyncSnapshot<LatestState> snapshot) {
            return PostGridView(
              refreshController: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              initialRefresh: LatestManager.data[widget.latestType].isEmpty,
              inRowCount: count,
              scrollController: scrollController,
              width: constraints.maxWidth,
              itemCount: LatestManager.data[widget.latestType].length,
              itemBuilder: (BuildContext context, int index) {
                var e = LatestManager.data[widget.latestType][index];
                return GestureDetector(
                  child: PostTile(
                    e,
                    widget.latestType.toString(),
                    number: index + 1,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, PostPage.route,
                        arguments: {'hero': widget.latestType, 'post': e});
                  },
                );
              },
              refreshFooter: CustomFooter(
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

  void normalizeRotationPosition() {
    var old = calc(scrollController.position.pixels, lastCount, h);

    var oldFirst = old[1];

    var newRow =
        ((isScrool ? (lastFirst = oldFirst) : lastFirst) / count).floor();

    if (lastCount != count) {
      var newPos = max(0.0, newRow * h);
      scrollController
          .animateTo(
        newPos,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      )
          .then((value) {
        isScrool = false;
      });
    }
  }

  List<int> calc(double scroll, int width, double height) {
    var index = (scroll * width / height);

    var row = index / width;

    if (row - row.floor() > 0.8)
      row = row.roundToDouble();
    else
      row = row.floorToDouble();

    var first = row * width;

    return [row.toInt(), first.toInt()];
  }

  @override
  bool get wantKeepAlive => true;
}
