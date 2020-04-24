import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/filmix/filmix.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';

class LatestManager {
  static var streams = {
    LatestType.news: BehaviorSubject<LatestState>.seeded(LatestState.loaded()),
    LatestType.serial:
        BehaviorSubject<LatestState>.seeded(LatestState.loaded()),
    LatestType.movie: BehaviorSubject<LatestState>.seeded(LatestState.loaded()),
    LatestType.multserials:
        BehaviorSubject<LatestState>.seeded(LatestState.loaded()),
    LatestType.multmovies:
        BehaviorSubject<LatestState>.seeded(LatestState.loaded()),
  };

  static var data = {
    LatestType.news: <MediaPost>[],
    LatestType.serial: <MediaPost>[],
    LatestType.movie: <MediaPost>[],
    LatestType.multserials: <MediaPost>[],
    LatestType.multmovies: <MediaPost>[],
  };

  static var page = {
    LatestType.news: 1,
    LatestType.serial: 1,
    LatestType.movie: 1,
    LatestType.multserials: 1,
    LatestType.multmovies: 1,
  };

  static Future refreshData(LatestType latestType) async {
    var result = await Filmix.latest(latestType);
    if (!result.hasError) {
      data[latestType] = result.data.posts;
      page[latestType] = 1;
    }
    if (result.hasError) {
      Fluttertoast.showToast(msg: result.error);
    }

    streams[latestType].add(LatestState.loaded());
  }

  static Future loadData(LatestType latestType) async {
    var result = await Filmix.latest(
      latestType,
      page: page[latestType] + 1,
    );

    if (!result.hasError) {
      data[latestType].addAll(result.data.posts);
      page[latestType]++;
    }
    if (result.hasError) {
      Fluttertoast.showToast(msg: result.error);
    }

    streams[latestType].add(LatestState.loaded());
  }
}

class LatestState {
  final bool isLoaded;

  LatestState.refresh() : isLoaded = false;
  LatestState.loaded() : isLoaded = true;
}
