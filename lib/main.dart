import 'package:filmix_watch/bloc/filter_manager.dart';
import 'package:filmix_watch/bloc/theme_bloc.dart';
import 'package:filmix_watch/pages/data/data_page.dart';
import 'package:filmix_watch/pages/main/main_page.dart';
import 'package:filmix_watch/pages/post_page.dart';
import 'package:flutter/material.dart';
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
    final ThemeBloc themeBloc = ThemeBloc();
    return StreamBuilder(
      initialData: themeBloc.initialTheme(),
      stream: themeBloc.themeDataStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Filmix Watch',
          theme: snapshot.data,
          routes: {
            '/': (_) => MainPage(),
            '/data': (_) => DataPage(),
            '/post': (_) => PostPage(),
          },
        );
      },
    );
  }
}
