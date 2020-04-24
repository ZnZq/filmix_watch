import 'dart:convert';

import 'package:filmix_watch/filmix/media_post.dart';
import 'package:hive/hive.dart';

class PostManager {
  static Map<int, MediaPost> posts = {};
  static Set<int> _postIds = {};

  static init() {
    var box = Hive.box('filmix');

    _postIds = (box.get('post-id-list', defaultValue: <int>[]) as List)
        .cast<int>()
        .toSet();

    for (var postId in _postIds) {
      if (box.containsKey('post-$postId')) {
        var postMap = jsonDecode(box.get('post-$postId')) as Map;
        var post = MediaPost.fromJson(postMap);
        posts[post.id] = post;
      }
    }
  }

  static remove(int postId) {
    var box = Hive.box('filmix');

    _postIds.remove(postId);
    posts.remove(postId);
    box.delete('post-$postId');

    box.put('post-id-list', _postIds.toList());
  }

  static saveIfNotExist(MediaPost post) {
    if (!_postIds.contains(post.id)) {
      save(post);
    }
  }

  static save([MediaPost post]) {
    var box = Hive.box('filmix');

    if (post != null) {
      _postIds.add(post.id);
      posts[post.id] = post;

      box.put('post-${post.id}', jsonEncode(post.toJson()));
    } else {
      for (var post in posts.entries) {
        box.put('post-${post.value.id}', jsonEncode(post.value.toJson()));
      }
    }

    box.put('post-id-list', _postIds.toList());
  }
}
