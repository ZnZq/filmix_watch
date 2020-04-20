import 'package:filmix_watch/bloc/theme_bloc.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/pages/search_page.dart';
import 'package:filmix_watch/widgets/app_drawer.dart';
import 'package:filmix_watch/widgets/post_grid.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
            _buildPopupMenuButton(context),
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

  PopupMenuButton _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (_) => <PopupMenuEntry>[
        CheckedPopupMenuItem(
          checked: Theme.of(context).brightness == ThemeData.dark().brightness,
          child: Text('Тёмная тема'),
          value: 'dark',
        ),
      ],
      onSelected: (item) => onSelected(context, item),
    );
  }

  void onSelected(context, item) {
    switch (item) {
      case 'dark':
        {
          var bloc = ThemeBloc();
          var isDark =
              Theme.of(context).brightness == ThemeData.dark().brightness;
          var box = Hive.box('filmix');
          box.put('dark', !isDark);
          bloc.selectedTheme.add(isDark ? ThemeData.light() : ThemeData.dark());
          break;
        }
    }
  }
}
