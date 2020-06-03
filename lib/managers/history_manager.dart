import 'dart:convert';

// import 'package:filmix_watch/managers/post_manager.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class HistoryManager {
  static BehaviorSubject _controller = BehaviorSubject();
  static BehaviorSubject get updateController => _controller;

  static List<History> histories;

  static addEpisode(HistoryItem item) {
    var history = History.getOrCreate();
    if (!histories.contains(history)) {
      histories.insert(0, history);
    }

    history.add(item);

    save();
  }

  static removeEpisode(int postId, int episodeId) {
    var history = History.getOrCreate();
    history.removeEpisode(postId, episodeId);
    if (history._history.isEmpty) histories.remove(history);

    save();
  }

  static removePost(int postId) {
    for (var history in histories.toList()) {
      history.remove(postId);
      if (history._history.isEmpty) histories.remove(history);
    }

    save();
  }

  static Map<String, Map<int, List<List<HistoryItem>>>> getHistory() {
    return {
      for (var history in histories) history.formattedDate: history.getHistory()
    };
  }

  static init() {
    var box = Hive.box('filmix');

    var list = jsonDecode(box.get('history', defaultValue: '[]')) as List;

    histories = list.map((e) => History.fromJson(e)).toList()
      ..sort(
        (a, b) => b.date.compareTo(a.date),
      );
  }

  static save() {
    var box = Hive.box('filmix');

    box.put(
      'history',
      jsonEncode(
        histories.map((e) => e.toJson()).toList(),
      ),
    );

    updateController.add(null);
  }
}

class History {
  static final format = DateFormat('dd.MM.yyyy');
  static final _histories = <DateTime, History>{};

  DateTime date;
  List<HistoryItem> _history;

  factory History.getOrCreate() {
    var date = getCurrentDate();
    return _histories.putIfAbsent(
      date,
      () => History._(date: date, history: []),
    );
  }

  factory History.fromJson(Map json) {
    var date = format.parse(json['date']);
    var history = (json['history'] as List)
            .map((e) => HistoryItem.fromJson(e))
            .toList() ??
        [];
    return _histories.putIfAbsent(
      date,
      () => History._(date: date, history: history),
    );
  }

  History._({this.date, List<HistoryItem> history}) : _history = history;

  Map toJson() {
    return {
      'date': formattedDate,
      'history': _history.map((e) => e.toJson()).toList(),
    };
  }

  String get formattedDate => format.format(date);

  void add(HistoryItem item) {
    var duplicate =
        _history.where((h) => h.postId == item.postId && h.id == item.id);

    if (duplicate.isEmpty) _history.add(item);
  }

  void remove(int postId) {
    _history.removeWhere((element) => element.postId == postId);
  }

  void removeEpisode(int postId, int episodeId) {
    _history.removeWhere(
        (element) => element.postId == postId && element.id == episodeId);
  }

  Map<int, List<List<HistoryItem>>> getHistory() {
    var posts = <int, List<List<HistoryItem>>>{
      for (var postId in _history.map((e) => e.postId).toSet()) postId: []
    };

    for (var postId in _history.map((e) => e.postId).toSet()) {
      var items = _history.where((h) => h.postId == postId).toList();

      if (items.length > 1) {
        items.sort((a, b) => a.id.compareTo(b.id));
      }

      if (items.length == 1) {
        posts[postId].add([items.first]);
      } else {
        var chunks = <List<HistoryItem>>[
          [items.first]
        ];

        var chunkIndex = 0;
        var lastId = items.first.id;

        for (var item in items.skip(1).toList()) {
          if (item.id == lastId + 1) {
            chunks[chunkIndex].add(item);
            lastId = item.id;
          } else {
            lastId = item.id;
            chunks.add([item]);
            chunkIndex++;
          }
        }

        for (var chunk in chunks) {
          posts[postId].add(chunk);
          // if (chunk.length == 1) {
          // } else {
          //   posts[postId].add([chunk.first, chunk.last]);
          // }
        }
      }
    }

    return posts;
  }

  static DateTime getCurrentDate() {
    var datetime = DateTime.now();
    return datetime.add(Duration(
      hours: -datetime.hour,
      minutes: -datetime.minute,
      seconds: -datetime.second,
      milliseconds: -datetime.millisecond,
      microseconds: -datetime.microsecond,
    ));
  }
}

class HistoryItem {
  int postId;
  int id;
  String title;

  HistoryItem({this.postId, this.title, this.id});

  HistoryItem.fromJson(Map json) {
    postId = json['postId'];
    title = json['title'];
    id = json['id'];
  }

  Map toJson() => {
        'postId': postId,
        'title': title,
        'id': id,
      };
}
