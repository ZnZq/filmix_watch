import 'package:connectivity/connectivity.dart';
import 'package:filmix_watch/filmix/cp1251.dart';
import 'package:filmix_watch/filmix/filmix.dart';
import 'package:filmix_watch/filmix/poster.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

class MediaPost {
  int id, like, dislike;
  String url,
      name,
      originName,
      /*genre, year,*/ description,
      date,
      added,
      quality;
  Poster poster;
  Map<String, String> items;

  PostType type;
  bool _loaded = false;
  bool get isLoaded => _loaded;

  bool _isEmpty = false;
  bool get isEmpty => _isEmpty;

  static final _facotry = <int, MediaPost>{};

  Future<MediaPost> loadData() async {
    if (isLoaded) return this;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return MediaPost.empty();
    }

    var response = await http.get(url, headers: Filmix.getHeader(xml: false));

    if (response.statusCode != 200) {
      return MediaPost.empty();
    }

    var body = decodeCp1251(response.body);

    var document = html.parse(body);

    var article = document.querySelector('article');

    like = int.parse(article.querySelector('.ratePos')?.text?.trim() ?? '0');
    dislike = int.parse(article.querySelector('.rateNeg')?.text?.trim() ?? '0');

    quality = article.querySelector('.quality')?.text?.trim() ?? '';
    date = article.querySelector('.date')?.text?.trim() ?? '';
    originName = article.querySelector('.origin-name')?.text?.trim() ?? '';
    added = article.querySelector('.added-info')?.text?.trim() ?? '';
    description = article.querySelector('.full-story')?.text?.trim() ?? '';

    type = added.isEmpty ? PostType.movie : PostType.serial;

    var itemsList = article
        .querySelectorAll('.item')
        .where((element) => element.classes.length > 1)
        .toList();

    items ??= {};

    for (var item in itemsList) {
      var key = item.querySelector('.label')?.text?.trim();
      var value = item.querySelector('.item-content')?.text?.trim();
      if (key != null && value != null) 
        this.items[key] = value.replaceAll(RegExp(r'\s+'), ' ');
    }

    _loaded = true;

    return this;
  }

  MediaPost.empty() : _isEmpty = true;

  factory MediaPost({
    int id,
    int like,
    int dislike,
    String url,
    String name,
    String originName,
    // String genre,
    // String year,
    String date,
    String added,
    String quality,
    // String translate,
    String description,
    Poster poster,
    PostType type,
    Map<String, String> items,
  }) {
    return _facotry.putIfAbsent(
      id,
      () => MediaPost._(
        id: id,
        description: description,
        // genre: genre,
        like: like,
        dislike: dislike,
        name: name,
        date: date,
        added: added,
        quality: quality,
        originName: originName,
        // translate: translate,
        url: url,
        // year: year,
        poster: poster,
        type: type,
        items: items,
      ),
    );
    // ..update(
    //     added: added,
    //     date: date,
    //     dislike: dislike,
    //     like: like,
    //     quality: quality,
    //     // year: year,
    //   );
  }

  // update({
  //   int like,
  //   int dislike,
  //   // String year,
  //   String date,
  //   String added,
  //   String quality,
  // }) {
  //   if (like != 0) this.like = like;
  //   if (dislike != 0) this.dislike = dislike;
  //   // if (year.isNotEmpty) this.year = year;
  //   if (date.isNotEmpty) this.date = date;
  //   if (added.isNotEmpty) this.added = added;
  //   if (quality.isNotEmpty) this.quality = quality;
  // }

  MediaPost._({
    this.id,
    this.like,
    this.dislike,
    this.url,
    this.name,
    this.originName,
    // this.genre,
    // this.year,
    this.date,
    this.added,
    this.quality,
    this.description,
    this.poster,
    this.type,
    this.items,
  });

  factory MediaPost.fromJson(Map json) {
    return _facotry.putIfAbsent(
      json['id'] ?? 0,
      () => MediaPost._(
        id: json['id'] ?? 0,
        description: json['description'] ?? '',
        // genre: json['genre'] ?? '',
        like: json['like'] ?? 0,
        dislike: json['dislike'] ?? 0,
        name: json['name'] ?? '',
        date: json['date'] ?? '',
        added: json['added'] ?? '',
        quality: json['quality'] ?? '',
        originName: json['originName'] ?? '',
        url: json['url'] ?? '',
        // year: json['year'] ?? '',
        poster: Poster(json['poster']),
        type: PostType.values[json['type'] ?? 0],
        items: Map<String, String>.from(json['items'] ?? <String, String>{})
      ),
    );
    // ..update(
    //     added: json['added'] ?? '',
    //     date: json['date'] ?? '',
    //     dislike: json['dislike'] ?? 0,
    //     like: json['like'] ?? 0,
    //     quality: json['quality'] ?? '',
    //     year: json['year'] ?? '',
    //   );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'like': like,
      'dislike': dislike,
      'url': url,
      'name': name,
      'originName': originName,
      // 'genre': genre,
      // 'year': year,
      'date': date,
      'added': added,
      'quality': quality,
      'description': description,
      'poster': poster.name,
      'type': type.index,
      'items': items,
    };
  }
}

enum PostType { unknown, serial, movie }

class MediaState {
  final bool isLoaded;

  MediaState.refresh() : isLoaded = false;
  MediaState.loaded() : isLoaded = true;
}
