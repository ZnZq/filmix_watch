import 'dart:core';

import 'package:filmix_watch/filmix/media/translate.dart';

import 'quality.dart';

class MovieTranslate extends Translate<Quality> {
  String title;
  List<Quality> media;

  MovieTranslate({
    this.title = '',
    this.media,
  }) {
    media ??= [];
  }

  MovieTranslate.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? '';
    media = json['media']?.map((e) => Quality.fromJson(e))?.cast<Quality>()?.toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'media': media.map((e) => e.toJson()).toList()};
  }
}
