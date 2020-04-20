import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class ThemeBloc {
  static ThemeBloc _instance;

  final Stream<ThemeData> themeDataStream;
  final Sink<ThemeData> selectedTheme;

  factory ThemeBloc() {
    final selectedTheme = PublishSubject<ThemeData>();
    final themeDataStream = selectedTheme.distinct();
    return _instance == null
        ? _instance = ThemeBloc._(themeDataStream, selectedTheme)
        : _instance;
  }

  ThemeBloc._(this.themeDataStream, this.selectedTheme);

  ThemeData initialTheme() {
    var box = Hive.box('filmix');
    var isDark = box.get('dark', defaultValue: true);
    return isDark ? ThemeData.dark() : ThemeData.light();
  }
}
