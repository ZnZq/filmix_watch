import 'package:filmix_watch/managers/auth_manager.dart';
import 'package:filmix_watch/managers/download_manager.dart';
import 'package:filmix_watch/managers/favorite_manager.dart';
import 'package:filmix_watch/managers/filter_manager.dart';
import 'package:filmix_watch/managers/history_manager.dart';
import 'package:filmix_watch/managers/media_manager.dart';
import 'package:filmix_watch/managers/mirror_manager.dart';
import 'package:filmix_watch/managers/post_manager.dart';
import 'package:filmix_watch/pages/auth_page.dart';
import 'package:filmix_watch/pages/data_page.dart';
import 'package:filmix_watch/pages/download_page.dart';
import 'package:filmix_watch/pages/favorite_page.dart';
import 'package:filmix_watch/pages/history_page.dart';
import 'package:filmix_watch/pages/main_page.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/pages/search_page.dart';
import 'package:filmix_watch/pages/settings_page.dart';
import 'package:filmix_watch/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(
    debug: true,
  );

  final docsPath = await path.getApplicationDocumentsDirectory();
  print(docsPath);
  Hive..init(docsPath.path);

  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  await Hive.openBox('filmix');
  MirrorManager.init();
  Settings.load();
  PostManager.init();
  MediaManager.init();
  FavoriteManager.init();
  HistoryManager.init();
  AuthManager.init();
  FilterManager.init();
  await DownloadManager.init();

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Filmix Watch',
      theme: ThemeData.dark(),
      routes: {
        MainPage.route: (_) => _willPopScope(MainPage()),
        DataPage.route: (_) => DataPage(),
        SearchPage.route: (_) => SearchPage(),
        SettingsPage.route: (_) => SettingsPage(),
        PostPage.route: (_) => PostPage(),
        AuthPage.route: (_) => AuthPage(),
        FavoritePage.route: (_) => FavoritePage(),
        HistoryPage.route: (_) => HistoryPage(),
        DownloadPage.route: (_) => DownloadPage(),
      },
    );
  }

  DateTime currentBackPressTime;

  Widget _willPopScope(Widget child) {
    return WillPopScope(
      child: child,
      onWillPop: onWillPop,
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
}
