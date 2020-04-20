class Poster {
  static final String _url = 'https://thumbs.filmix.co/posters'; 
  static final RegExp regex = RegExp(r'\/(?<name>[\w-]+\.jpg)');
  String _name;

  String get w40 => '$_url/thumbs/w40/$_name';
  String get w220 => '$_url/thumbs/w220/$_name';
  String get original => '$_url/orig/$_name';

  Poster(String url) {
    var m = regex.firstMatch(url);
    assert(m != null);
    _name = m.namedGroup('name');
  }
}