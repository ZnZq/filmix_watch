import 'season.dart';

abstract class Translation {
  String name;

  Translation(this.name);
}

class MovieTranslation extends Translation {
  final String name;
  final Map<String, String> qualities;

  MovieTranslation({this.name, this.qualities}) : super(name);
}

class SerialTranslation extends Translation {
  final String name;
  final List<Season> seasons;

  SerialTranslation({this.name, this.seasons}) : super(name);
}
