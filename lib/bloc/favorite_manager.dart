import 'dart:convert';

import 'package:filmix_watch/bloc/post_manager.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class FavoriteManager {
  static Map<int, FavoriteItem> _favoriteItems;

  static Map<FavoriteTab, Map<PostType, List<int>>> posts;

  static BehaviorSubject _controller = BehaviorSubject();
  static BehaviorSubject get updateController => _controller;

  static init() {
    _favoriteItems = {};
    posts = {
      FavoriteTab.favorite: <PostType, List<int>>{
        PostType.serial: [],
        PostType.movie: [],
      },
      FavoriteTab.future: <PostType, List<int>>{
        PostType.serial: [],
        PostType.movie: [],
      },
      FavoriteTab.process: <PostType, List<int>>{
        PostType.serial: [],
        PostType.movie: [],
      },
      FavoriteTab.completed: <PostType, List<int>>{
        PostType.serial: [],
        PostType.movie: [],
      },
    };

    var box = Hive.box('filmix');

    var list = jsonDecode(box.get('favorites', defaultValue: '[]')) as List;
    var fav = list.map((e) => FavoriteItem.fromJson(e)).toList();

    for (var type in PostType.values) {
      posts[FavoriteTab.favorite][type] =
          (box.get('${FavoriteTab.favorite}-$type', defaultValue: <int>[])
                  as List)
              .cast<int>()
              .toList();
      posts[FavoriteTab.future][type] =
          (box.get('${FavoriteTab.future}-$type', defaultValue: <int>[])
                  as List)
              .cast<int>()
              .toList();
      posts[FavoriteTab.process][type] =
          (box.get('${FavoriteTab.process}-$type', defaultValue: <int>[])
                  as List)
              .cast<int>()
              .toList();
      posts[FavoriteTab.completed][type] =
          (box.get('${FavoriteTab.completed}-$type', defaultValue: <int>[])
                  as List)
              .cast<int>()
              .toList();
    }

    for (var f in fav) {
      _favoriteItems[f.postId] = f;
    }
  }

  static save() {
    var box = Hive.box('filmix');

    var list = _favoriteItems.entries.map((e) => e.value.toJson()).toList();

    for (var type in PostType.values) {
      box.put('${FavoriteTab.favorite}-$type', posts[FavoriteTab.favorite][type]);
      box.put('${FavoriteTab.future}-$type', posts[FavoriteTab.future][type]);
      box.put('${FavoriteTab.process}-$type', posts[FavoriteTab.future][type]);
      box.put('${FavoriteTab.completed}-$type', posts[FavoriteTab.completed][type]);
    }

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

  static List<MediaPost> getFavoriteTabPosts(FavoriteTab tab, PostType type) {
    return posts[tab][type].map((e) => PostManager.posts[e]).toList();
  }

  static void handleMenuSelect(String selected, MediaPost post) {
    if (selected == null) return;

    var item = getFavoriteItem(post.id);

    switch (selected) {
      case 'favorite':
        {
          if (item.isFavorite) {
            posts[FavoriteTab.favorite][post.type].remove(item.postId);
          } else {
            posts[FavoriteTab.favorite][post.type].add(item.postId);
          }
          item.isFavorite = !item.isFavorite;
          break;
        }
      default:
        {
          // Удаляем из страницы, если она есть
          if (item.state != FavoriteState.none) {
            posts[FavoriteTab.values[item.state.index]][post.type].remove(item.postId);
          }

          // Получаем состояние новое сосотояние
          FavoriteState newState = FavoriteState.values[int.parse(selected)];

          // Если новое состояние - не текущее, то добовляем на страницу
          if (item.state != newState) {
            posts[FavoriteTab.values[newState.index]][post.type].add(item.postId);
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
