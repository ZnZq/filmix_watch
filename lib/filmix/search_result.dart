import 'package:filmix_watch/filmix/media_post.dart';
import 'package:filmix_watch/filmix/poster.dart';

class SearchResult {
  final int id;
  final String title;
  final String originalName;
  final String year;
  final String link;
  final String categories;
  final Poster poster;
  final String lastSerie;
  final String letter;
  PostType get type => lastSerie.isEmpty ? PostType.movie : PostType.serial;

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
