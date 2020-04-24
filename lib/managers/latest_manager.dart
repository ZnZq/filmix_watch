import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/filmix/filmix.dart';
import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';

class LatestManager {
  static var streams = {
    for (var latest in LatestType.values)
      latest: BehaviorSubject<LatestState>.seeded(LatestState.loaded())
  };

  static var data = {
    for (var latest in LatestType.values)
      latest: <MediaPost>[]
  };

  static var page = {
    for (var latest in LatestType.values)
      latest: 1
  };

  static Future refreshData(LatestType latestType) async {
    Result<PostResult> result;
    if (latestType == LatestType.popularity) {
      result = await Filmix.popularity();
    } else {
      result = await Filmix.latest(latestType);
    }
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
