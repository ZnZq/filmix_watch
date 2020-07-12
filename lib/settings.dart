import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class Settings {
  static BehaviorSubject _controller = BehaviorSubject();
  static BehaviorSubject get updateController => _controller;

  static bool smartScroll;
  static bool freeFullHD;
  static Set<String> fullHDCodes;
  static bool showPostQuality,
      showPostAdded,
      showPostTime,
      showPostType,
      showPostNumber,
      showPostLike;
  static String downloadFolder;

  Settings.fromJson(Map<String, dynamic> json) {
    smartScroll = json['smartScroll'] ?? true;
    freeFullHD = json['freeFullHD'] ?? true;
    if (json['fullHDCodes'] != null) {
      fullHDCodes = Set<String>.from(jsonDecode(json['fullHDCodes']) as List);
    } else {
      fullHDCodes = {
        'b067090d21fbb988502675ef79745ff6b1e825',
        '2e2ffdec9fd12ab24985961f88849e31410d0c',
        'b06d7340024b900c9e256ccac9ea2ca33ca7b2',
        'b2b9545efaeaebf26e85d54c620283da1cdf2b',
      };
    }
    showPostQuality = json['showPostQuality'] ?? true;
    showPostAdded = json['showPostAdded'] ?? true;
    showPostTime = json['showPostTime'] ?? true;
    showPostType = json['showPostType'] ?? true;
    showPostNumber = json['showPostNumber'] ?? true;
    showPostLike = json['showPostLike'] ?? true;
    downloadFolder = json['downloadFolder'];
    if (downloadFolder == null || downloadFolder.isEmpty) {
      downloadFolder = '/storage/emulated/0/';
    }
    var dir = Directory(downloadFolder);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  static Map<String, dynamic> toJson() {
    return {
      'smartScroll': smartScroll,
      'freeFullHD': freeFullHD,
      'fullHDCodes': jsonEncode(fullHDCodes.toList()),
      'showPostQuality': showPostQuality,
      'showPostAdded': showPostAdded,
      'showPostTime': showPostTime,
      'showPostType': showPostType,
      'showPostNumber': showPostNumber,
      'showPostLike': showPostLike,
      'downloadFolder': downloadFolder,
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
