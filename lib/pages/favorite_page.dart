import 'package:filmix_watch/managers/favorite_manager.dart';
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
          actions: [
            PopupMenuButton(
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('Удалить все'),
                  value: 'delete',
                )
              ],
              onSelected: (selected) async {
                if (selected == 'delete') {
                  var result = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Удаление'),
                      content: Text(
                          'Вы действительно хотите удалить все из избранного?'),
                      actions: [
                        FlatButton(
                          child: Text('Отмена'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        FlatButton(
                          textColor: Colors.red,
                          child: Text('Удалить'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );

                  if (result) {
                    FavoriteManager.clear();
                  }
                }
              },
            )
          ],
        ),
        drawer: AppDrawer(currentRoute: FavoritePage.route),
        body: TabBarView(
          children: [
            PostFavoriteList(FavoriteTab.favorite),
            PostFavoriteList(FavoriteTab.future),
            PostFavoriteList(FavoriteTab.process),
            PostFavoriteList(FavoriteTab.completed),
          ],
        ),
      ),
    );
  }
}
