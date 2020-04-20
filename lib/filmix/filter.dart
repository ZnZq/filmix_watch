import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:filmix_watch/filmix/filmix.dart';
import 'package:filmix_watch/filmix/result.dart';
import 'package:http/http.dart' as http;
import 'enums.dart';

enum FilterCategory { serials, filmy, multserialy, multfilms }

extension on FilterType {
  String get text {
    return toString().split('.').last;
  }

  String get char {
    var t = text;
    switch (t) {
      case 'categories':
        return 'g';
      case 'rip':
        return 'q';
      default:
        return t[0];
    }
  }
}

class Filter {
  final SortType sortType;
  final SortMode sortMode;
  final FilterCategory category;
  final Set<String> filters;

  const Filter({
    this.sortType = SortType.date,
    this.sortMode = SortMode.up_down,
    this.category = FilterCategory.serials,
    this.filters = const {},
  });

  String get filter =>
      '${category.toString().split('.').last}${filters.isNotEmpty ? '/(filters.toList()..sort()).join("-")' : ''}';

  static Future<Result<Map<String, String>>> getFilter(
      FilterType filterType) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none)
        return Result.error('Нет интернета');

      var response = await http.post(
        'https://filmix.co/engine/ajax/get_filter.php',
        body: {'scope': 'cat', 'type': filterType.text},
        headers: Filmix.getHeader(),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var result = <String, String>{};

        var typeChar = filterType.char;

        for (MapEntry entry in data.entries) {
          var key = entry.key.toString();
          if (key.indexOf('f') == 0) {
            key = key.substring(1);
          }

          result['$typeChar$key'] = entry.value;
        }

        return Result.data(result);
      } else
        return Result.error('Status ${response.statusCode}. ${response.body}');
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}
