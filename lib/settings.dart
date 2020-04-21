import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class Settings {
  static BehaviorSubject _controller = BehaviorSubject();
  static BehaviorSubject get updateController => _controller;

  static bool smartScroll;
  static bool showPostQuality,
      showPostAdded,
      showPostTime,
      showPostType,
      showPostNumber,
      showPostLike;

  Settings.fromJson(Map<String, dynamic> json) {
    smartScroll = json['smartScroll'] ?? true;
    showPostQuality = json['showPostQuality'] ?? true;
    showPostAdded = json['showPostAdded'] ?? true;
    showPostTime = json['showPostTime'] ?? true;
    showPostType = json['showPostType'] ?? true;
    showPostNumber = json['showPostNumber'] ?? true;
    showPostLike = json['showPostLike'] ?? true;
  }

  static Map<String, dynamic> toJson() {
    return {
      'smartScroll': smartScroll,
      'showPostQuality': showPostQuality,
      'showPostAdded': showPostAdded,
      'showPostTime': showPostTime,
      'showPostType': showPostType,
      'showPostNumber': showPostNumber,
      'showPostLike': showPostLike,
    };
  }

  static load() {
    var box = Hive.box('filmix');
    var json = box.get('settings', defaultValue: '{}');
    Settings.fromJson(jsonDecode(json));
    updateController.add(null);
  }

  static save() {
    var box = Hive.box('filmix');
    box.put('settings', jsonEncode(toJson()));
    updateController.add(null);
  }
}
