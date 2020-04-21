import 'quality.dart';

class Episode {
  String title;
  String id;
  bool viewed;
  List<Quality> qualities;

  Episode({
    this.title = '',
    this.id = '',
    this.viewed = false,
    this.qualities
  }) {
    qualities ??= [];
  }

  Episode.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? '';
    id = json['id'] ?? '';
    viewed = json['viewed'] ?? false;
    qualities = json['qualities']?.map((e) => Quality.fromJson(e))?.cast<Quality>()?.toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
      'viewed': viewed,
      'qualities': qualities.map((e) => e.toJson()).toList()
    };
  }
}
