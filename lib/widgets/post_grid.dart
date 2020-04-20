import 'package:filmix_watch/bloc/latest_manager.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/tiles/post_tile.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PostGrid extends StatefulWidget {
  final LatestType latestType;

  PostGrid(this.latestType);

  @override
  PostGridState createState() => PostGridState();
}

class PostGridState extends State<PostGrid>
    with AutomaticKeepAliveClientMixin<PostGrid> {
  RefreshController _refreshController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(
        initialRefresh: LatestManager.data[widget.latestType].isEmpty);
  }

  void _onRefresh() async {
    await LatestManager.refreshData(widget.latestType);
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await LatestManager.loadData(widget.latestType);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var count = constraints.maxWidth > constraints.maxHeight ? 3 : 2;
        return StreamBuilder<LatestState>(
          stream: LatestManager.streams[widget.latestType],
          builder: (BuildContext context, AsyncSnapshot<LatestState> snapshot) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              // enablePullUp: widget.latestType != LatestType.news,
              enablePullUp: true,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: GridView.count(
                padding: EdgeInsets.all(8),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                crossAxisCount: count,
                childAspectRatio: ((constraints.maxWidth - 32) / count) / 275,
                children: LatestManager.data[widget.latestType]
                    .map(
                      (e) => GestureDetector(
                        child: PostTile(e, widget.latestType),
                        onTap: () {
                          Navigator.pushNamed(context, '/post', arguments: {
                            'hero': widget.latestType,
                            'post': e
                          });
                        },
                      ),
                    )
                    .toList(),
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
