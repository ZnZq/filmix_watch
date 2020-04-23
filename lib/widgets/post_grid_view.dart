import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PostGridView extends StatefulWidget {
  final double tileHeight;
  final double width;
  final int itemCount;
  final int inRowCount;
  final Function(BuildContext, int) itemBuilder;
  final ScrollController scrollController;
  final RefreshController refreshController;
  final Widget refreshFooter;
  final Function onRefresh, onLoading;
  final bool initialRefresh;

  PostGridView({
    @required this.itemCount,
    @required this.width,
    @required this.inRowCount,
    @required this.itemBuilder,
    @required this.scrollController,
    this.refreshController,
    this.refreshFooter,
    this.onRefresh,
    this.onLoading,
    this.initialRefresh = false,
    this.tileHeight = 275,
  });

  @override
  _PostGridViewState createState() => _PostGridViewState();
}

class _PostGridViewState extends State<PostGridView>
   /* with AutomaticKeepAliveClientMixin<PostGridView> */{
  bool isScrool = true;
  Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = GridView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.all(8),
      itemCount: widget.itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.inRowCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio:
            ((widget.width - (widget.inRowCount + 1) * 8) / widget.inRowCount) /
                widget.tileHeight,
      ),
      itemBuilder: widget.itemBuilder,
    );

    if (widget.onRefresh == null && widget.onLoading == null) {
      return child;
    }

    return SmartRefresher(
      controller: widget.refreshController,
      enablePullDown: widget.onRefresh != null,
      enablePullUp: widget.onLoading != null,
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoading,
      footer: widget.refreshFooter,
      child: child,
    );
  }

  // @override
  // bool get wantKeepAlive => true;
}
