import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/media/translate.dart';
import 'package:filmix_watch/tiles/episode_tile.dart';
import 'package:filmix_watch/tiles/movie_tile.dart';
import 'package:flutter/material.dart';

class MediaExplorer extends StatefulWidget {
  final MediaPost post;
  final List<Translate> translates;

  MediaExplorer(this.post, this.translates);

  @override
  _MediaExplorerState createState() => _MediaExplorerState();
}

class _MediaExplorerState extends State<MediaExplorer> {
  var pages = [];
  List<String> nav = [];
  List<List> navData = [];

  String title = '';

  @override
  void initState() {
    super.initState();

    pages = widget.post.type == PostType.serial
        ? ['Переводы', 'Сезоны', 'Серии']
        : ['Переводы', 'Фильм'];

    title = pages.first;
    navData = [widget.translates];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16)),
                if (nav.isNotEmpty)
                  Text(
                    nav.join(' > '),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
              ],
            ),
            height: 50,
            width: double.infinity,
          ),
          Divider(height: 0),
          widget.post.type == PostType.serial
              ? _buildSerialExplorer()
              : _buildMovieExplorer(),
        ],
      ),
      onWillPop: () {
        if (nav.isEmpty || DefaultTabController.of(context).index == 0)
          return Future.value(true);

        setState(() {
          nav.removeLast();
          title = pages[nav.length];
          navData.removeLast();
        });

        return Future.value(false);
      },
    );
  }

  Widget _buildMovieExplorer() {
    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Widget child = Container();

          switch (nav.length) {
            case 0:
              child = _translateTile(index);
              break;
            case 1:
              child = MovieTile(
                quality: navData.last[index],
                mediaPost: widget.post,
              );
              break;
          }

          return child;
        },
        separatorBuilder: (_, __) => Divider(height: 0),
        itemCount: navData.last.length,
      ),
    );
  }

  Widget _buildSerialExplorer() {
    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Widget child = Container();

          switch (nav.length) {
            case 0:
              child = _translateTile(index);
              break;
            case 1:
              child = ListTile(
                title: Text(navData.last[index].title),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  nav.add(navData.last[index].title);
                  setState(() {
                    title = pages[2];
                    navData.add(navData.last[index].episodes);
                  });
                },
              );
              break;
            case 2:
              child = EpisodeTile(navData.last[index]);
              break;
          }

          return child;
        },
        separatorBuilder: (_, __) => Divider(height: 0),
        itemCount: navData.last.length,
      ),
    );
  }

  ListTile _translateTile(int index) {
    return ListTile(
      title: Text(widget.translates[index].title),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        nav.add(navData.last[index].title);
        setState(() {
          title = pages[1];
          navData.add(navData.last[index].media);
        });
      },
    );
  }
}
