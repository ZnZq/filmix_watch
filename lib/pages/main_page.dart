import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/pages/favorite_page.dart';
import 'package:filmix_watch/pages/search_page.dart';
import 'package:filmix_watch/widgets/app_drawer.dart';
import 'package:filmix_watch/widgets/post_grid.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  static final String route = '/';
  static final String title = 'Главная';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Популярное'),
              Tab(text: 'Новинки'),
              Tab(text: 'Сериалы'),
              Tab(text: 'Фильмы'),
              Tab(text: 'Мультсериалы'),
              Tab(text: 'Мультфильмы'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pushNamed(context, SearchPage.route);
              },
            ),
            IconButton(
              icon: Icon(Icons.star_border),
              onPressed: () {
                Navigator.pushNamed(context, FavoritePage.route);
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: TabBarView(
          children: [
            PostGrid(LatestType.popularity, showInfo: false),
            PostGrid(LatestType.news),
            PostGrid(LatestType.serial),
            PostGrid(LatestType.movie),
            PostGrid(LatestType.multserials),
            PostGrid(LatestType.multmovies),
          ],
        ),
      ),
    );
  }
}
