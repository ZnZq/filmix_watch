import 'package:filmix_watch/bloc/favorite_manager.dart';
import 'package:filmix_watch/widgets/post_favorite_grid.dart';
import 'package:filmix_watch/widgets/post_grid_view.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  static final String route = '/favorite';
  static final String title = 'Избранное';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Избранное'),
              Tab(text: 'На будущее'),
              Tab(text: 'Завершенное'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PostFavoriteList(FavoriteTab.favorite),
            PostFavoriteList(FavoriteTab.future),
            PostFavoriteList(FavoriteTab.completed),
          ],
        ),
      ),
    );
  }
}
