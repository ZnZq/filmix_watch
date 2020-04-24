import 'dart:convert';

import 'package:filmix_watch/filmix/media/episode.dart';
import 'package:filmix_watch/managers/history_manager.dart';
import 'package:filmix_watch/managers/post_manager.dart';
import 'package:filmix_watch/filmix/filmix.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/media/movie_translate.dart';
import 'package:filmix_watch/filmix/media/serial_translate.dart';
import 'package:filmix_watch/filmix/media/translate.dart';
import 'package:filmix_watch/filmix/result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class MediaManager {
  static final _manager = <int, MediaManager>{};
  static Set<int> mediaIds = {};

  static init() {
    var box = Hive.box('filmix');
    mediaIds = box.keys
        .toList()
        .where((key) => key.toString().startsWith('media-'))
        .map((e) => int.parse(e.toString().split('-').last))
        .toSet();
  }

  static remove(int postId) {
    var box = Hive.box('filmix');
    box.delete('media-$postId');

    var viewRegex = RegExp('view-$postId-');

    for (var key in box.keys.toList()) {
      var m = viewRegex.firstMatch(key.toString());
      if (m != null) {
        box.delete(key);
      }
    }

    mediaIds.remove(postId);
    HistoryManager.removePost(postId);
    MediaManager(PostManager.posts[postId]).controller.add([]);
  }

  final MediaPost post;
  BehaviorSubject<List<Translate>> _controller;
  BehaviorSubject<List<Translate>> get controller => _controller;
  List<Translate> translates = [];

  factory MediaManager(MediaPost post) {
    return _manager.putIfAbsent(post.id, () => MediaManager._(post));
  }

  MediaManager._(this.post) {
    _controller = BehaviorSubject<List<Translate>>.seeded([]);
    loadIfHasMedia();
  }

  loadIfHasMedia() {
    var box = Hive.box('filmix');
    if (box.containsKey('media-${post.id}')) {
      loadMedia();
    }
  }

  loadMedia([int wait = 0]) async {
    controller.add(null);
    if (wait > 0) await Future.delayed(Duration(milliseconds: wait));
    var box = Hive.box('filmix');
    if (box.containsKey('media-${post.id}')) {
      var json = box.get('media-${post.id}', defaultValue: '[]');
      var list = jsonDecode(json) as List;
      switch (post.type) {
        case PostType.serial:
          {
            translates = list.map((e) => SerialTranslate.fromJson(e)).toList();
            break;
          }
        case PostType.movie:
          {
            translates = list.map((e) => MovieTranslate.fromJson(e)).toList();
            break;
          }
      }
      controller.add(translates);
      return;
    }

    refresh();
  }

  refresh() async {
    controller.add(null);
    Result<List<Translate>> result;
    switch (post.type) {
      case PostType.serial:
        {
          result = await Filmix.getSerial(post.id);
          break;
        }
      case PostType.movie:
        {
          result = await Filmix.getMovie(post.id);
          break;
        }
    }

    if (result.hasError) {
      Fluttertoast.showToast(msg: result.error);
      translates = [];
    } else {
      translates = result.data;

      var box = Hive.box('filmix');
      box.put('media-${post.id}', jsonEncode(translates));

      PostManager.save(post);
      mediaIds.add(post.id);
    }
    controller.add(translates);
  }

  static setView(int postId, Episode episode, bool view,
      {bool saveToHistory = false}) {
    var box = Hive.box('filmix');
    if (view) {
      box.put('view-$postId-${episode.id}', view);
    } else {
      box.delete('view-$postId-${episode.id}');
    }

    if (saveToHistory) {
      if (view) {
        HistoryManager.addEpisode(HistoryItem(
          postId: postId,
          title: episode.title,
          id: episode.id,
        ));
      } else {
        HistoryManager.removeEpisode(postId, episode.id);
      }
    }
  }

  static bool getView(int postId, int episodeId) {
    var box = Hive.box('filmix');
    return box.get('view-$postId-$episodeId', defaultValue: false);
  }
}
