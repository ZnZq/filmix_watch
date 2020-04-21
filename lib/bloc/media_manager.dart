import 'dart:convert';

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

  final MediaPost post;
  BehaviorSubject<List<Translate>> _controller;
  BehaviorSubject<List<Translate>> get controller => _controller;

  factory MediaManager(MediaPost post) {
    return _manager.putIfAbsent(post.id, () => MediaManager._(post));
  }

  MediaManager._(this.post) {
    _controller = BehaviorSubject<List<Translate>>.seeded([]);
    loadIfHasMedia();
  }

  loadIfHasMedia() {
    var box = Hive.box('filmix');
    if (box.containsKey(post.id)) {
      loadMedia();
    }
  }

  loadMedia([int wait = 0]) async {
    controller.add(null);
    if (wait > 0) await Future.delayed(Duration(milliseconds: wait));
    var box = Hive.box('filmix');
    if (box.containsKey(post.id)) {
      var json = box.get(post.id, defaultValue: '[]');
      var list = jsonDecode(json) as List;
      var transletes = <Translate>[];
      switch (post.type) {
        case PostType.serial:
          {
            transletes = list.map((e) => SerialTranslate.fromJson(e)).toList();
            break;
          }
        case PostType.movie:
          {
            transletes = list.map((e) => MovieTranslate.fromJson(e)).toList();
            break;
          }
      }
      controller.add(transletes);
      return;
    }

    refresh();
  }

  refresh() async {
    controller.add(null);
    var translates = <Translate>[];
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
    } else {
      translates = result.data;

      var box = Hive.box('filmix');
      box.put(post.id, jsonEncode(translates));
    }

    controller.add(translates);
  }
}
