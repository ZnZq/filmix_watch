import 'package:filmix_watch/managers/media_manager.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/widgets/media_view.dart';
import 'package:filmix_watch/widgets/post_info.dart';
import 'package:flutter/material.dart';

class PostPage extends StatelessWidget {
  static final String route = '/post';

  String hero;

  @override
  Widget build(BuildContext context) {
    var map = ModalRoute.of(context).settings.arguments as Map;
    var post = map['post'] as MediaPost;
    hero = map['hero'].toString();
    var bloc = MediaManager(post);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: '$hero${post.id}name',
            child: material(
              Text(
                post.name,
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ),
          actions: [
            StreamBuilder(
              stream: bloc.controller,
              initialData: bloc.controller.value,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                return IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    bloc.refresh();
                  },
                );
              },
            ),
            SizedBox(width: 8),
          ],
        ),
        body: TabBarView(
          children: [
            PostInfo(post, hero),
            MediaView(post),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(text: 'Информация'),
            Tab(text: 'Просмотр'),
          ],
        ),
      ),
    );
  }

  Widget material(Widget child) {
    return Material(
      color: Colors.transparent,
      child: child,
    );
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
