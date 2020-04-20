import 'package:filmix_watch/filmix/enums.dart';
import 'package:filmix_watch/filmix/filter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class FilterManager {
  static Map<FilterType, BehaviorSubject<FilterState>> streams = {
    FilterType.translation:
        BehaviorSubject<FilterState>.seeded(FilterState.loaded()),
    FilterType.rip: BehaviorSubject<FilterState>.seeded(FilterState.loaded()),
    FilterType.categories:
        BehaviorSubject<FilterState>.seeded(FilterState.loaded()),
    FilterType.countries:
        BehaviorSubject<FilterState>.seeded(FilterState.loaded()),
    FilterType.years: BehaviorSubject<FilterState>.seeded(FilterState.loaded()),
  };

  static Map<FilterType, Map<String, String>> data = {
    FilterType.translation: {},
    FilterType.rip: {},
    FilterType.categories: {},
    FilterType.countries: {},
    FilterType.years: {},
  };

  static void updateData(FilterType type) async {
    FilterManager.streams[type].add(FilterState.refresh());
    var result = await Filter.getFilter(type);
    if (!result.hasError) {
      var box = Hive.box('filmix');
      data[type] = result.data;
      box.put(type.toString(), result.data);
    } else {
      Fluttertoast.showToast(msg: result.error);
    }

    FilterManager.streams[type].add(FilterState.loaded());
  }

  static void init() {
    var box = Hive.box('filmix');
    for (var type in FilterType.values) {
      var typeData = box.get(type.toString(), defaultValue: {}) as Map;
      data[type] = typeData.cast<String, String>();
    }
  }
}

class FilterState {
  final bool isLoaded;

  FilterState.refresh() : isLoaded = false;
  FilterState.loaded() : isLoaded = true;
}
