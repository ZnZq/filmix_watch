import 'package:cached_network_image/cached_network_image.dart';
import 'package:filmix_watch/filmix/media/translation.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/tiles/movie_tile.dart';
import 'package:filmix_watch/tiles/season_tile.dart';
import 'package:flutter/material.dart';

class PostPage extends StatelessWidget {
  static final String route = '/post';

  String hero;
  ScrollController scrollController;

  PostPage() {
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    var map = ModalRoute.of(context).settings.arguments as Map;
    var post = map['post'] as MediaPost;
    hero = map['hero'].toString();

    if (post.translations.isEmpty && post.controller.value.isLoaded)
      post.loadMedia();

    // Future.delayed(Duration(milliseconds: 100), () {
    //   if (post.translations.isEmpty) post.loadMedia();
    // });

    return Scaffold(
      body: StreamBuilder<MediaState>(
        stream: post.controller,
        initialData: post.controller.value,
        builder: (BuildContext context, AsyncSnapshot<MediaState> snapshot) {
          return DefaultTabController(
            length: snapshot.data.isLoaded ? post.translations.length : 1,
            child: NestedScrollView(
              controller: scrollController,
              headerSliverBuilder: (context, value) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildBackground(post),
                    ),
                    forceElevated: value,
                    centerTitle: true,
                    title: _buildTitle(post),
                    bottom: TabBar(
                      isScrollable: true,
                      tabs: snapshot.data.isLoaded
                          ? post.translations
                              .map(
                                (e) => Tab(
                                  child: Text(
                                    e.name,
                                    style: TextStyle(shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 2,
                                      )
                                    ]),
                                  ),
                                ),
                              )
                              .toList()
                          : [
                              Tab(
                                  child: Text('Загрузка...',
                                      style: TextStyle(shadows: [
                                        Shadow(
                                            color: Colors.black, blurRadius: 2)
                                      ])))
                            ],
                    ),
                    actions: [
                      IconButton(
                        icon: snapshot.data.isLoaded
                            ? Icon(Icons.refresh, color: Colors.blue)
                            : CircularProgressIndicator(),
                        onPressed: snapshot.data.isLoaded
                            ? () => post.loadMedia()
                            : null,
                      ),
                      SizedBox(width: 8)
                    ],
                  ),
                ];
              },
              body: TabBarView(
                children: snapshot.data.isLoaded
                    ? post.translations.map((e) {
                        Widget child = Text(e.name);
                        if (e is MovieTranslation) {
                          if (e.qualities.isEmpty)
                            child = Center(
                              child: Text(
                                  'Заблокировано по просьбе правообладателя'),
                            );
                          else
                            child = MovieTile(
                              movieTranslation: e,
                              mediaPost: post,
                            );
                        }
                        if (e is SerialTranslation) {
                          if (e.seasons.isEmpty)
                            child = Center(
                              child: Text(
                                  'Заблокировано по просьбе правообладателя'),
                            );
                          else
                            child = SeasonTile(e);
                        }

                        return child;
                      }).toList()
                    : [Center(child: CircularProgressIndicator())],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(MediaPost post) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Hero(
        tag: '$hero${post.name}',
        child: Material(
          color: Colors.transparent,
          child: Text(
            post.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            ),
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(MediaPost post) {
    return Hero(
      tag: '$hero${post.poster.original}',
      child: CachedNetworkImage(
        imageUrl: post.poster.original,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}