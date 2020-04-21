import 'package:filmix_watch/bloc/auth_manager.dart';
import 'package:filmix_watch/bloc/filter_manager.dart';
import 'package:filmix_watch/pages/auth_page.dart';
import 'package:filmix_watch/pages/data_page.dart';
import 'package:filmix_watch/pages/main_page.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:filmix_watch/pages/search_page.dart';
import 'package:filmix_watch/pages/settings_page.dart';
import 'package:filmix_watch/settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final docsPath = await path.getApplicationDocumentsDirectory();
  print(docsPath);
  Hive..init(docsPath.path);

  runApp(
    FutureBuilder(
      future: Hive.openBox('filmix'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Settings.load();
          AuthManager.init();
          FilterManager.init();
          return App();
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    ),
  );
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
