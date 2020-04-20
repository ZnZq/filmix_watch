extension on SortMode {
  String get mode {
    switch (this) {
      case SortMode.up_down:
        return 'desc';
      case SortMode.down_up:
        return 'asc';
      default:
        return '';
    }
  }
}

enum SortType { date, year, rating, news_read, comm_num, title }

enum SortMode { up_down, down_up }

enum FilterType {
  translation,
  categories,
  countries,
  years,
  rip,
}

enum LatestType { news, serial, movie, multserials, multmovies }
