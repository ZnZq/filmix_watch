import 'quality.dart';

class Episode {
  String title;
  String _id;
  String get id => _id;
  // bool viewed;
  List<Quality> qualities;

  Episode({
    this.title = '',
    // this.id = '',
    // this.viewed = false,
    this.qualities
  }) {
    qualities ??= [];
  }

  static final _idRegex = RegExp(r'[а-яА-Я\s]');

  Episode.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    _id = title.replaceAll(_idRegex, '');
    // id = json['id'] ?? '';
    // viewed = json['viewed'] ?? false;
    qualities = json['qualities']?.map((e) => Quality.fromJson(e))?.cast<Quality>()?.toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      // 'id': id,
      // 'viewed': viewed,
      'qualities': qualities.map((e) => e.toJson()).toList()
    };
  }
}
