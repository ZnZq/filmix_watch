import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:filmix_watch/filmix/cp1251.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/media/episode.dart';
import 'package:filmix_watch/filmix/media/movie_translate.dart';
import 'package:filmix_watch/filmix/media/quality.dart';
import 'package:filmix_watch/filmix/media/season.dart';
import 'package:filmix_watch/filmix/media/serial_translate.dart';
import 'package:filmix_watch/filmix/poster.dart';
import 'package:filmix_watch/filmix/result.dart';
import 'package:filmix_watch/filmix/user_data.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

import 'enums.dart';
import 'filter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'player_js.dart';
import 'search_result.dart';

class Filmix {
  /*
    do:             cat
    category:       filmy/c11-c18-c22-c28-c112
    cstart:         2
    requested_url:  filmy/c11-c18-c22-c28-c112/page/2/
    =======================================================
    do:             cat
    category:       filmy/c11-c18-c22-c28-c112
    requested_url:  filmy/c11-c18-c22-c28-c112
  */

  static Map<String, String> getHeader(
      {int perPageNews = 60, Map<String, String> cookie = const {}}) {
    return {
      'x-requested-with': 'XMLHttpRequest',
      'cookie': {
        'dle_user_id': user?.id ?? '',
        'dle_password': user?.password ?? '',
        'per_page_news': perPageNews.toString(),
        ...cookie
      }.entries.map((e) => '${e.key}=${e.value}').join('; ')
    };
  }

  static UserData _user;
  static UserData get user => _user;

  static logout() {
    var box = Hive.box('filmix');
    box.put('user_id', '');
    box.put('password', '');
    _user = null;
  }

  static Future<String> auth(String login, String password) async {
    try {
      var response = await http.post(
        'https://filmix.co/engine/ajax/user_auth.php',
        body: {
          'login_name': login,
          'login_password': password,
          'login': 'submit',
        },
        headers: {'x-requested-with': 'XMLHttpRequest'},
      );

      if (response.body != 'AUTHORIZED') {
        return response.body;
      }

      var regexCookie =
          RegExp(r'dle_user_id=(?<user_id>\d+).*dle_password=(?<password>\w+)');

      var m = regexCookie.firstMatch(response.headers['set-cookie']);

      if (m == null) {
        return 'INVALID COOKIE';
      }

      var userId = m.namedGroup('user_id');
      var pass = m.namedGroup('password');

      var box = Hive.box('filmix');
      box.put('user_id', userId);
      box.put('password', pass);

      var hasData = await getUser(userId, pass);
      if (hasData)
        return 'AUTHORIZED';
      else
        return 'FAIL LOAD USER DATA';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<bool> getUser(String userId, String password) async {
    try {
      var response = await http.get(
        'https://filmix.co/my_news',
        headers: {'cookie': 'dle_user_id=$userId; dle_password=$password'},
      );

      if (response.statusCode != 200) {
        _user = null;
        return false;
      }

      var document = html.parse(response.body);
      var header = document.getElementById('header');
      var login = header.querySelector('.login');
      if (login.classes.contains('guest')) {
        _user = null;
        return false;
      }

      var avatar = login.querySelector('.avatar').attributes['src'];

      _user = UserData(
        id: userId,
        password: password,
        name: login.querySelector('.user-name').text.trim(),
        avatar: avatar == '/templates/Filmix/dleimages/noavatar.png'
            ? 'https://filmix.co$avatar'
            : avatar,
        profie: login.querySelector('.user-profile').attributes['href'],
      );
      return true;
    } catch (e) {
      _user = null;
      return true;
    }
  }

  static String _genArgs(int page, Filter filter) {
    return {
      'do': 'cat',
      'category': filter.filter,
      if (page > 1) 'cstart': page,
      'requested_url': '${filter.filter}${page > 1 ? '/page/$page/' : ''}',
    }.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  static var rand = Random();
  static String randomString(int length) {
    var codeUnits = List.generate(length, (index) => rand.nextInt(33) + 89);
    return String.fromCharCodes(codeUnits);
  }

  static final postTypeRegex = RegExp(
      r'(<span class="mark">|)(Мультсериалы|Сериалы)(<\/span>|)(,{0,1}\s{0,})');

  static Future<Result<List<MediaPost>>> search2(String text) async {
    try {
      var response = await http.post(
        'https://filmix.co/engine/ajax/sphinx_search.php',
        headers: getHeader(),
        body: {'story': text},
      );

      if (response.statusCode != 200) {
        return Result.error('Status ${response.statusCode}. ${response.body}');
      }

      var document = html.parse(response.body);

      var posts = Filmix.readArticles(document.querySelectorAll('article'));

      return Result.data(posts);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  static Future<Result<List<SearchResult>>> search(String text) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none)
        return Result.error('Нет интернета');

      var response = await http.get(
        'https://filmix.co/api/v2/suggestions?search_word=${Uri.encodeFull(text.replaceAll(' ', '+'))}',
        headers: getHeader(),
      );

      if (response.statusCode != 200) {
        return Result.error('Status ${response.statusCode}. ${response.body}');
      }

      var json = jsonDecode(response.body) as List;

      var result = <SearchResult>[];

      for (var res in json) {
        var categories = res['categories'].toString();
        categories =
            categories.replaceAllMapped(postTypeRegex, (m) => '${m[2]}${m[4]}');

        result.add(SearchResult(
          id: res['id'],
          title: res['title'],
          originalName: res['original_name'],
          year: res['year'].toString(),
          link: res['link'],
          categories: categories,
          poster: Poster(res['poster']),
          lastSerie: res['last_serie'],
          letter: res['letter'],
        ));
      }

      return Result.data(result);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  static Map<String, String> _latestType(LatestType type) {
    switch (type) {
      case LatestType.movie:
        return {'main_page_cat': '0'};
      case LatestType.serial:
        return {'main_page_cat': '7'};
      case LatestType.multmovies:
        return {'main_page_cat': '14'};
      case LatestType.multserials:
        return {'main_page_cat': '93'};
      default:
        return {};
    }
  }

  static isolateLatestEntry(message) async {
    ReceivePort port = ReceivePort();
    message.send(port.sendPort);

    var msg = await port.first;

    List datas = msg[0];
    String data = datas[0];
    bool needDecode = datas[1];
    SendPort replyPort = msg[1];

    var body = needDecode ? decodeCp1251(data) : data;

    var document = html.parse(body);

    var currentPage = int.parse(document
        .querySelector('.navigation span[data-number]')
        .attributes['data-number']);
    var pageCount = (document
            .querySelectorAll('.navigation a:not([class])')
            .map((a) => int.parse(a.attributes['data-number']))
            .toList()
              ..add(currentPage))
        .reduce(max);

    var posts = Filmix.readArticlesMap(document.querySelectorAll('article'));

    replyPort.send([currentPage, pageCount, posts]);
  }

  static Future sendReceive(SendPort send, message) {
    ReceivePort receivePort = ReceivePort();
    send.send([message, receivePort.sendPort]);
    return receivePort.first;
  }

  static Future<Result<PostResult>> latest(
    LatestType type, {
    int page = 1,
  }) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none)
        return Result.error('Нет интернета');

      page = max(1, page);

      var needDecode = page > 1;

      var response = await http.get(
        needDecode
            ? 'https://filmix.co/page/$page/'
            : 'https://filmix.co/loader.php?requested_url=%2F',
        headers: getHeader(cookie: _latestType(type)),
      );

      if (response.statusCode != 200) {
        return Result.error('Status ${response.statusCode}. ${response.body}');
      }

      ReceivePort receivePort = ReceivePort();

      await Isolate.spawn(isolateLatestEntry, receivePort.sendPort);

      SendPort sendPort = await receivePort.first;

      var postResult = await sendReceive(sendPort, [response.body, needDecode]);
      var currentPage = postResult[0];
      var pageCount = postResult[1];
      var posts = postResult[2];

      var result = Result.data(PostResult(
        currentPage: currentPage,
        countPages: pageCount,
        posts: readArticlesFromMap(posts),
      ));

      return result;
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  static Future<Result<PostResult>> posts({
    int page = 1,
    SearchSize searchSize = SearchSize.size60,
    Filter filter = const Filter(),
  }) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none)
        return Result.error('Нет интернета');

      var size = (searchSize.index + 1) * 15;
      page = max(1, page);

      var response = await http.post(
        'https://filmix.co/loader.php?${_genArgs(page, filter)}',
        body: {
          'dlenewssortby': filter.sortType.toString().split('.').last,
          'dledirection': filter.sortMode == SortMode.up_down ? 'desc' : 'asc',
          'set_new_sort': 'dle_sort_cat',
          'set_direction_sort': 'dle_direction_cat',
        },
        headers: getHeader(perPageNews: size),
      );

      if (response.statusCode != 200) {
        return Result.error('Status ${response.statusCode}. ${response.body}');
      }

      var document = html.parse(response.body);

      var currentPage = int.parse(document
          .querySelector('.navigation span[data-number]')
          .attributes['data-number']);
      var pageCount = (document
              .querySelectorAll('.navigation a:not([class])')
              .map((a) => int.parse(a.attributes['data-number']))
              .toList()
                ..add(currentPage))
          .reduce(max);

      var posts = readArticles(document.querySelectorAll('article'));

      return Result.data(PostResult(
        currentPage: currentPage,
        countPages: pageCount,
        posts: posts,
      ));
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  static List<Map> readArticlesMap(List<Element> articles) {
    return articles.map((article) {
      var like = int.parse(article
              .querySelector('.short .like .counter .icon-like')
              ?.text
              ?.trim() ??
          '0');

      var dislike = int.parse(article
              .querySelector('.short .like .counter .icon-dislike')
              ?.text
              ?.trim() ??
          '0');

      var quality = article.querySelector('.quality')?.text?.trim() ?? '';

      var date = article.querySelector('.date')?.text?.trim() ?? '';

      var poster = article.querySelector('.short .poster').attributes['src'];
      var url = article.querySelector('.watch').attributes['href'];
      var name = article.querySelector('.name')?.text?.trim() ?? '';
      var originName =
          article.querySelector('.origin-name')?.text?.trim() ?? '';

      var genre =
          article.querySelector('.category .item-content')?.text?.trim() ?? '';
      var year =
          article.querySelector('.year .item-content')?.text?.trim() ?? '';
      var translate =
          article.querySelector('.translate .item-content')?.text?.trim() ?? '';

      var description = article.querySelector('p')?.text?.trim() ?? '';

      var id = int.parse(article.attributes['data-id']);

      var added = article.querySelector('.added-info')?.text?.trim() ?? '';

      var type = added.isEmpty ? PostType.movie : PostType.serial;
      return {
        'id': id,
        'description': description,
        'genre': genre,
        'like': like,
        'dislike': dislike,
        'added': added,
        'quality': quality,
        'name': name,
        'date': date,
        'originName': originName,
        'translate': translate,
        'url': url,
        'year': year,
        'poster': poster,
        'type': type,
      };
    }).toList();
  }

  static List<MediaPost> readArticlesFromMap(List<Map> mediaPosts) {
    return mediaPosts
        .map((e) => MediaPost(
              id: e['id'],
              description: e['description'],
              genre: e['genre'],
              like: e['like'],
              dislike: e['dislike'],
              added: e['added'],
              quality: e['quality'],
              name: e['name'],
              date: e['date'],
              originName: e['originName'],
              // translate: e['translate'],
              url: e['url'],
              year: e['year'],
              poster: Poster(e['poster']),
              type: e['type'],
            ))
        .toList();
  }

  static List<MediaPost> readArticles(List<Element> articles) {
    return readArticlesMap(articles)
        .map((e) => MediaPost(
              id: e['id'],
              description: e['description'],
              genre: e['genre'],
              like: e['like'],
              dislike: e['dislike'],
              added: e['added'],
              quality: e['quality'],
              name: e['name'],
              date: e['date'],
              originName: e['originName'],
              // translate: e['translate'],
              url: e['url'],
              year: e['year'],
              poster: Poster(e['poster']),
              type: e['type'],
            ))
        .toList();
  }

  static final _linkRegex =
      RegExp(r'\[(?<q>\d+K{0,}(p|\sU{0,1}HD|))\](?<url>https.*\.mp4)');

  static Future<Result<Map>> _getData(int id) async {
    try {
      var response = await http.post(
        'https://filmix.co/api/movies/player_data',
        body: {'post_id': '$id', 'showfull': 'true'},
        headers: getHeader(),
      );

      if (response.statusCode != 200) {
        return Result.error('Status ${response.statusCode}. ${response.body}');
      }

      return Result.data(jsonDecode(response.body));
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  static isolategetMovieEntry(message) async {
    ReceivePort port = ReceivePort();
    message.send(port.sendPort);

    var msg = await port.first;
    Map data = msg[0];
    SendPort replyPort = msg[1];

    var movieTranslations = <MovieTranslate>[];

    if (data['message']['translations']['video'] is List) {
      replyPort.send(<Map>[]);
      return;
    }

    for (var video in data['message']['translations']['video'].keys) {
      var pjs = PlayerJS({
        'file': data['message']['translations']['video'][video],
      });

      var json = await pjs.init();

      var episodeFiles = json.split(',');
      var qualities = <Quality>[];

      for (var file in episodeFiles) {
        var m = _linkRegex.firstMatch(file);
        if (m != null) {
          qualities.add(Quality(
            quality: m.namedGroup('q'),
            url: m.namedGroup('url'),
          ));
        }
      }

      qualities.sort((a, b) => a.compareTo(b));

      movieTranslations.add(MovieTranslate(
        title: video,
        media: qualities,
      ));
    }

    var result = <Map>[];

    for (var trans in movieTranslations) {
      result.add(trans.toJson());
    }

    replyPort.send(result);
  }

  static Future<Result<List<MovieTranslate>>> getMovie(int filmId) async {
    try {
      var data = await _getData(filmId);

      if (data.hasError) return Result.error(data.error, false);

      ReceivePort receivePort = ReceivePort();

      await Isolate.spawn(isolategetMovieEntry, receivePort.sendPort);

      SendPort sendPort = await receivePort.first;

      var movieTranslationsList =
          await sendReceive(sendPort, data.data) as List;

      return Result.data(
        movieTranslationsList.map((e) => MovieTranslate.fromJson(e)).toList(),
      );

      // if (movieTranslationsList.isEmpty) {
      //   return Result.data([]);
      // }

      // var movieTranslations = movieTranslationsList
      //     .map((e) => MovieTranslate(
      //           title: e['name'],
      //           media: e['qualities'],
      //         ))
      //     .toList();

      // return Result.data(movieTranslations);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  static isolategetSerialEntry(message) async {
    ReceivePort port = ReceivePort();
    message.send(port.sendPort);

    var msg = await port.first;
    Map data = msg[0];
    SendPort replyPort = msg[1];

    var serialTranslations = <SerialTranslate>[];

    if (data['message']['translations']['video'] is List) {
      replyPort.send(<Map>[]);
      return;
    }

    for (var video in data['message']['translations']['video'].keys) {
      var pjs = PlayerJS({
        'file': data['message']['translations']['video'][video],
      });

      var json = await pjs.init();

      var seasons = <Season>[];
      var seasonsMapList = jsonDecode(json) as List;

      for (var seasonMap in seasonsMapList) {
        var seasonTitle = seasonMap['title'].trim();
        var episodes = <Episode>[];
        for (var episodeMap in seasonMap['folder']) {
          var episodeTitle = episodeMap['title'];
          var episodeId = episodeMap['id'];
          var episodeFiles = episodeMap['file'].split(',');
          var qualities = <Quality>[];

          for (var file in episodeFiles) {
            var m = _linkRegex.firstMatch(file);
            if (m != null) {
              qualities.add(Quality(
                quality: m.namedGroup('q'),
                url: m.namedGroup('url'),
              ));
            }
          }

          qualities.sort((a, b) => a.compareTo(b));

          episodes.add(Episode(
              title: episodeTitle, /*id: episodeId, */qualities: qualities));
        }
        seasons.add(Season(title: seasonTitle, episodes: episodes));
      }

      serialTranslations.add(SerialTranslate(
        title: video,
        media: seasons,
      ));
    }

    var result = <Map>[];

    for (var trans in serialTranslations) {
      result.add(trans.toJson());
    }

    replyPort.send(result);
  }

  static Future<Result<List<SerialTranslate>>> getSerial(int serialId) async {
    try {
      var data = await _getData(serialId);

      if (data.hasError) return Result.error(data.error, false);

      ReceivePort receivePort = ReceivePort();

      await Isolate.spawn(isolategetSerialEntry, receivePort.sendPort);

      SendPort sendPort = await receivePort.first;

      var serialTranslationsList =
          await sendReceive(sendPort, data.data) as List;

      return Result.data(
        serialTranslationsList.map((e) => SerialTranslate.fromJson(e)).toList(),
      );

      // if (serialTranslationsList.isEmpty) {
      //   return Result.data([]);
      // }

      // var serialTranslations = serialTranslationsList
      //     .map((t) => SerialTranslate(
      //           title: t['name'],
      //           seasons: (t['seasons'] as List)
      //               .map((s) => Season(
      //                     title: s['title'],
      //                     episodes: (s['episodes'] as List)
      //                         .map((e) => Episode(
      //                               id: e['id'],
      //                               title: e['title'],
      //                               qualities: e['qualities'],
      //                             ))
      //                         .toList(),
      //                   ))
      //               .toList(),
      //         ))
      //     .toList();

      // return Result.data(serialTranslationsList.map((e) => SerialTranslate.fromJson(e)).toList());
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}

enum SearchSize {
  size15,
  size30,
  size45,
  size60,
}

enum SearchType { serial, film }

class PostResult {
  final int currentPage;
  final int countPages;
  final List<MediaPost> posts;

  PostResult({
    this.currentPage,
    this.countPages,
    this.posts,
  });
}
