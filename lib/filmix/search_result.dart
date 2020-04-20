import 'filmix.dart';

class SearchResult {
  final int id;
  final String title;
  final String originalName;
  final String year;
  final String link;
  final String categories;
  final String poster;
  final String lastSerie;
  final String letter;
  bool get isMovie => !Filmix.postTypeRegex.hasMatch(categories);

  SearchResult({
    this.id,
    this.title,
    this.originalName,
    this.year,
    this.link,
    this.categories,
    this.poster,
    this.lastSerie,
    this.letter,
  });
}
