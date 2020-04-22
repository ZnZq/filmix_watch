import 'package:filmix_watch/bloc/media_manager.dart';

import 'episode.dart';

class Season {
  String title;
  List<Episode> episodes;

  double progress(int postId) {
    return episodes.where((ep) => MediaManager.getView(postId, ep.id)).length /
        episodes.length;
  }

  Season({
    this.title = '',
    this.episodes,
  }) {
    episodes ??= [];
  }

  Season.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? 'Сезон';
    episodes = json['episodes']
            ?.map((e) => Episode.fromJson(e))
            ?.cast<Episode>()
            ?.toList() ??
        [];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'episodes': episodes.map((e) => e.toJson()).toList()
    };
  }
}
