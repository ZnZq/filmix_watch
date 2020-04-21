import 'dart:core';

import 'package:filmix_watch/filmix/media/translate.dart';

import 'season.dart';

class SerialTranslate extends Translate<Season> {
  String title;
  List<Season> media;

  SerialTranslate({
    this.title = '',
    this.media,
  }) {
    media ??= [];
  }

  SerialTranslate.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? '';
    media = json['media']?.map((e) => Season.fromJson(e))?.cast<Season>()?.toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'media': media.map((e) => e.toJson()).toList()};
  }
}
