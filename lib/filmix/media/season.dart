import 'episode.dart';

class Season {
  String title;
  List<Episode> episodes;

  Season({
    this.title = '',
    this.episodes,
  }) {
    episodes ??= [];
  }

  Season.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? 'Сезон';
    episodes = json['episodes']?.map((e) => Episode.fromJson(e))?.cast<Episode>()?.toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'episodes': episodes.map((e) => e.toJson()).toList()
    };
  }
}