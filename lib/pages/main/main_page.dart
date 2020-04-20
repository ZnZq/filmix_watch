import 'package:filmix_watch/bloc/theme_bloc.dart';
import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/widgets/post_grid.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Filmix Watch'),
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
              _buildPopupMenuButton(context),
            ],
          ),
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
      ),
      onWillPop: onWillPop,
    );
  }

  PopupMenuButton _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (_) => <PopupMenuEntry>[
        PopupMenuItem(
          child: Text('Данные'),
          value: 'data',
        ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(
          checked: Theme.of(context).brightness == ThemeData.dark().brightness,
          child: Text('Тёмная тема'),
          value: 'dark',
        ),
      ],
      onSelected: (item) => onSelected(context, item),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Нажмите "Назад" еще раз, что бы выйти');
      return Future.value(false);
    }
    return Future.value(true);
  }

  void onSelected(context, item) {
    switch (item) {
      case 'data':
        Navigator.pushNamed(context, '/data');
        break;
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
