import 'package:filmix_watch/filmix/filmix.dart';
import 'package:filmix_watch/filmix/search_result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';

class SearchManager {
  static final searchController =
      BehaviorSubject<SearchState>.seeded(SearchState.loaded());

  static List<SearchResult> data = [];

  static void search(String text) async {
    searchController.add(SearchState.refresh());
    data.clear();

    var result = await Filmix.search(text);

    if (!result.hasError) {
      data = result.data;
    }
    if (result.hasError) {
      Fluttertoast.showToast(msg: result.error);
    }

    searchController.add(SearchState.loaded());
  }
}

class SearchState {
  final bool isLoaded;

  SearchState.refresh() : isLoaded = false;
  SearchState.loaded() : isLoaded = true;
}
