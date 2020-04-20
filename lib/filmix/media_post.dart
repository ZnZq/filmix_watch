import 'package:filmix_watch/filmix/filmix.dart';
import 'package:filmix_watch/filmix/media/translation.dart';
import 'package:filmix_watch/filmix/poster.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';

class MediaPost {
  final int id, like, dislike;
  final String url,
      name,
      originName,
      genre,
      year,
      translate,
      description,
      date,
      added;
  final Poster poster;
  final PostType type;
  final List<Translation> translations;

  final BehaviorSubject<MediaState> controller;

  static final _facotry = <int, MediaPost>{};

  factory MediaPost({
    int id,
    int like,
    int dislike,
    String url,
    String name,
    String originName,
    String genre,
    String year,
    String date,
    String added,
    String translate,
    String description,
    Poster poster,
    PostType type,
  }) {
    return _facotry.putIfAbsent(
      id,
      () => MediaPost._(
        id: id,
        description: description,
        genre: genre,
        like: like,
        dislike: dislike,
        name: name,
        date: date,
        added: added,
        originName: originName,
        translate: translate,
        url: url,
        year: year,
        poster: poster,
        type: type,
      ),
    );
  }

  MediaPost._({
    this.id,
    this.like,
    this.dislike,
    this.url,
    this.name,
    this.originName,
    this.genre,
    this.year,
    this.date,
    this.added,
    this.translate,
    this.description,
    this.poster,
    this.type,
  })  : translations = [],
        controller = BehaviorSubject<MediaState>.seeded(MediaState.loaded());

  Future loadMedia() async {
    controller.add(MediaState.refresh());
    translations.clear();
    switch (type) {
      case PostType.serial:
        var result = await Filmix.getSerial(id);
        if (result.hasError) {
          Fluttertoast.showToast(msg: result.error);
        } else
          translations.addAll(result.data);
        break;
      case PostType.movie:
        var result = await Filmix.getMovie(id);
        if (result.hasError) {
          Fluttertoast.showToast(msg: result.error);
        } else
          translations.addAll(result.data);
        break;
    }
    controller.add(MediaState.loaded());
  }
}

enum PostType { serial, movie }

class MediaState {
  final bool isLoaded;

  MediaState.refresh() : isLoaded = false;
  MediaState.loaded() : isLoaded = true;
}
