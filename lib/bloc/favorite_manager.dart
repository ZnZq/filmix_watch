import 'dart:convert';

import 'package:filmix_watch/bloc/post_manager.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class FavoriteManager {
  static Map<int, FavoriteItem> _favoriteItems;

  static Map<FavoriteTab, List<int>> posts;

  static BehaviorSubject _controller = BehaviorSubject();
  static BehaviorSubject get updateController => _controller;

  static _initVars() {
    _favoriteItems = {};
    posts = {
      FavoriteTab.favorite: [],
      FavoriteTab.future: [],
      FavoriteTab.process: [],
      FavoriteTab.completed: [],
    };
  }

  static init() {
    _initVars();

    var box = Hive.box('filmix');

    var list = jsonDecode(box.get('favorites', defaultValue: '[]')) as List;
    var fav = list.map((e) => FavoriteItem.fromJson(e)).toList();

    posts[FavoriteTab.favorite] =
        (box.get('${FavoriteTab.favorite}', defaultValue: <int>[]) as List)
            .cast<int>()
            .toList();
    posts[FavoriteTab.future] =
        (box.get('${FavoriteTab.future}', defaultValue: <int>[]) as List)
            .cast<int>()
            .toList();
    posts[FavoriteTab.process] =
        (box.get('${FavoriteTab.process}', defaultValue: <int>[]) as List)
            .cast<int>()
            .toList();
    posts[FavoriteTab.completed] =
        (box.get('${FavoriteTab.completed}', defaultValue: <int>[]) as List)
            .cast<int>()
            .toList();

    for (var f in fav) {
      _favoriteItems[f.postId] = f;
    }
  }

  static clear() {
    _initVars();

    var box = Hive.box('filmix');

    box.delete('favorites');

    for (var tab in FavoriteTab.values) {
      var viewRegex = RegExp('^$tab');

      for (var key in box.keys.toList()) {
        var m = viewRegex.firstMatch('$key');
        if (m != null) {
          box.delete('$key');
        }
      }
    }

    updateController.add(null);
  }

  static save() {
    var box = Hive.box('filmix');

    var list = _favoriteItems.entries.map((e) => e.value.toJson()).toList();

    box.put('${FavoriteTab.favorite}', posts[FavoriteTab.favorite]);
    box.put('${FavoriteTab.future}', posts[FavoriteTab.future]);
    box.put('${FavoriteTab.process}', posts[FavoriteTab.process]);
    box.put('${FavoriteTab.completed}', posts[FavoriteTab.completed]);

    box.put('favorites', jsonEncode(list));
    updateController.add(null);
  }

  static showFavoriteMenu(
    BuildContext context,
    RelativeRect position,
    MediaPost post,
  ) async {
    var selected = await showMenu(
      context: context,
      position: position,
      items: buildPopup(post),
    );

    handleMenuSelect(selected, post);
  }

  static FavoriteItem getFavoriteItem(int postId) => _favoriteItems.putIfAbsent(
        postId,
        () => FavoriteItem(postId: postId),
      );

  static List<MediaPost> getFavoriteTabPosts(FavoriteTab tab) {
    return posts[tab].map((e) => PostManager.posts[e]).toList();
  }

  static void handleMenuSelect(String selected, MediaPost post) {
    if (selected == null) return;

    var item = getFavoriteItem(post.id);

    switch (selected) {
      case 'favorite':
        {
          if (item.isFavorite) {
            posts[FavoriteTab.favorite].remove(item.postId);
          } else {
            posts[FavoriteTab.favorite].add(item.postId);
          }
          item.isFavorite = !item.isFavorite;
          break;
        }
      default:
        {
          // Удаляем из страницы, если она есть
          if (item.state != FavoriteState.none) {
            posts[FavoriteTab.values[item.state.index]].remove(item.postId);
          }

          // Получаем состояние новое сосотояние
          FavoriteState newState = FavoriteState.values[int.parse(selected)];

          // Если новое состояние - не текущее, то добовляем на страницу
          if (item.state != newState) {
            posts[FavoriteTab.values[newState.index]].add(item.postId);
          }

          //Обновляем состояние
          item.state = item.state == newState ? FavoriteState.none : newState;
        }
    }

    if (!item.isFavorite && item.state == FavoriteState.none) {
      PostManager.remove(item.postId);
      _favoriteItems.remove(item.postId);
    } else {
      PostManager.save(post);
    }

    save();
  }

  static List<PopupMenuEntry> buildPopup(MediaPost post) {
    return [
      CheckedPopupMenuItem<String>(
        checked: _favoriteItems[post.id]?.isFavorite ?? false,
        child: Text('Избранное'),
        value: 'favorite',
      ),
      PopupMenuDivider(height: 0),
      CheckedPopupMenuItem<String>(
        checked:
            _favoriteItems[post.id]?.state == FavoriteState.future ?? false,
        child: Text('На будущее'),
        value: FavoriteState.future.index.toString(),
      ),
      CheckedPopupMenuItem<String>(
        checked:
            _favoriteItems[post.id]?.state == FavoriteState.process ?? false,
        child: Text('В процессе'),
        value: FavoriteState.process.index.toString(),
      ),
      CheckedPopupMenuItem<String>(
        checked:
            _favoriteItems[post.id]?.state == FavoriteState.completed ?? false,
        child: Text('Завершенное'),
        value: FavoriteState.completed.index.toString(),
      ),
    ];
  }
}

enum FavoriteState { future, process, completed, none }
enum FavoriteTab { future, process, completed, favorite }

class FavoriteItem {
  bool isFavorite;
  FavoriteState state;
  int postId;

  FavoriteItem({
    @required this.postId,
    this.isFavorite = false,
    this.state = FavoriteState.none,
  });

  FavoriteItem.fromJson(Map<String, dynamic> json) {
    isFavorite = json['isFavorite'] ?? false;
    state = FavoriteState.values[json['state']] ?? FavoriteState.none;
    postId = json['postId'];
  }

  Map<String, dynamic> toJson() {
    return {
      'isFavorite': isFavorite,
      'state': state.index,
      'postId': postId,
    };
  }
}
