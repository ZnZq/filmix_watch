import 'package:filmix_watch/filmix/enums.dart';
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
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
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
          ],
        ),
        drawer: AppDrawer(),
        body: TabBarView(
          children: [
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
