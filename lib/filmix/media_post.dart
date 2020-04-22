import 'package:filmix_watch/filmix/poster.dart';
import 'package:rxdart/rxdart.dart';

class MediaPost {
  int id, like, dislike;
  String url,
      name,
      originName,
      genre,
      year,
      // translate,
      description,
      date,
      added,
      quality;
  Poster poster;
  PostType type;

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
    String quality,
    // String translate,
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
        quality: quality,
        originName: originName,
        // translate: translate,
        url: url,
        year: year,
        poster: poster,
        type: type,
      ),
    )..update(
        added: added,
        date: date,
        dislike: dislike,
        like: like,
        quality: quality,
        year: year,
      );
  }

  update({
    int like,
    int dislike,
    String year,
    String date,
    String added,
    String quality,
  }) {
    this.like = like;
    this.dislike = dislike;
    this.year = year;
    this.date = date;
    this.added = added;
    this.quality = quality;
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
    this.quality,
    this.description,
    this.poster,
    this.type,
  });

  factory MediaPost.fromJson(Map<String, dynamic> json) {
    return _facotry.putIfAbsent(
      json['id'] ?? 0,
      () => MediaPost._(
        id: json['id'] ?? 0,
        description: json['description'] ?? 0,
        genre: json['genre'] ?? 0,
        like: json['like'] ?? '',
        dislike: json['dislike'] ?? '',
        name: json['name'] ?? '',
        date: json['date'] ?? '',
        added: json['added'] ?? '',
        quality: json['quality'] ?? '',
        originName: json['originName'] ?? '',
        url: json['url'] ?? '',
        year: json['year'] ?? '',
        poster: Poster(json['poster']),
        type: PostType.values[json['type']],
      ),
    )..update(
        added: json['added'] ?? '',
        date: json['date'] ?? '',
        dislike: json['dislike'] ?? '',
        like: json['like'] ?? '',
        quality: json['quality'] ?? '',
        year: json['year'] ?? '',
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'like': like,
      'dislike': dislike,
      'url': url,
      'name': name,
      'originName': originName,
      'genre': genre,
      'year': year,
      'date': date,
      'added': added,
      'quality': quality,
      'description': description,
      'poster': poster.name,
      'type': type.index,
    };
  }
}

enum PostType { serial, movie }

class MediaState {
  final bool isLoaded;

  MediaState.refresh() : isLoaded = false;
  MediaState.loaded() : isLoaded = true;
}
