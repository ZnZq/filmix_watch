import 'package:filmix_watch/bloc/favorite_manager.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/widgets/app_drawer.dart';
import 'package:filmix_watch/widgets/post_favorite_list.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  static final String route = '/favorite';
  static final String title = 'Избранное';

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  PostType selectedType = PostType.serial;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(FavoritePage.title),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Избранное'),
              Tab(text: 'На будущее'),
              Tab(text: 'В процессе'),
              Tab(text: 'Завершенное'),
            ],
          ),
        ),
        drawer: AppDrawer(currentRoute: FavoritePage.route),
        body: TabBarView(
          children: [
            PostFavoriteList(FavoriteTab.favorite, selectedType),
            PostFavoriteList(FavoriteTab.future, selectedType),
            PostFavoriteList(FavoriteTab.process, selectedType),
            PostFavoriteList(FavoriteTab.completed, selectedType),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedType.index,
          items: [
            BottomNavigationBarItem(title: Text('Сериалы'), icon: Icon(Icons.movie)),
            BottomNavigationBarItem(title: Text('Фильмы'), icon: Icon(Icons.local_movies)),
          ],
          onTap: (index) {
            setState(() {
              selectedType = PostType.values[index];
            });
          },
        ),
      ),
    );
  }
}
