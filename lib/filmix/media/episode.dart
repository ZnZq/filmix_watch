import 'quality.dart';

class Episode {
  String title;
  int _id;
  int get id => _id;
  List<Quality> qualities;

  Episode({
    this.title = '',
    this.qualities
  }) {
    qualities ??= [];
  }

  // static final _idRegex = RegExp(r'[а-яА-Я\s]');
  // static final idRegex = RegExp(r'[^\d]+');
  static var idRegex = RegExp(r'Сери[яи]\s{0,}(?<episode>[\d-]+)\s{0,}(\(Сезон\s(?<season>\d+)\)){0,}');

  Episode.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    // _id = title.replaceAll(_idRegex, '');
    // _id = int.parse(title.replaceAll(idRegex, '').split('').reversed.join());
    var m = idRegex.firstMatch(title);
    if (m != null) {
      _id = int.parse('${m.groupNames.contains('season') ? m.namedGroup('season') : '0'}0${m.namedGroup('episode').split('-').last.padLeft(8, '0')}');
      // print('$title - $id');
    }
    qualities = json['qualities']?.map((e) => Quality.fromJson(e))?.cast<Quality>()?.toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'qualities': qualities.map((e) => e.toJson()).toList()
    };
  }
}
