import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class MirrorManager {
  static BehaviorSubject _controller = BehaviorSubject();
  static BehaviorSubject get updateController => _controller;

  static List<String> mirrors = [];
  static String currentMirror = '';

  static init() {
    var box = Hive.box('filmix');

    currentMirror = box.get('currentMirror', defaultValue: 'filmix.co');

    mirrors = (box.get(
      'mirrors',
      defaultValue: [
        'filmix.co',
        'filmix.guru',
        'filmix.online',
        'filmix.email',
      ],
    ) as List)
        .cast<String>()
        .toList();
  }

  static save() {
    var box = Hive.box('filmix');

    box.put('mirrors', mirrors);
    box.put('currentMirror', currentMirror);
  }

  static var mirrorRegex = RegExp(r'(?<mirror>filmix\.\w{2,})');

  static bool removeMirror(String mirror) {
    if (currentMirror == mirror) {
      return false;
    }
    mirrors.remove(mirror);
    save();
    updateController.add(null);
    return false;
  }

  static selectMirror(String mirror) {
    if (mirrors.contains(mirror)) {
      currentMirror = mirror;
    }
    save();
    updateController.add(null);
  }

  static bool addMirror(String mirror) {
    var m = mirrorRegex.firstMatch(mirror);
    if (m != null) {
      mirrors.add(m.namedGroup('mirror'));
      save();
      updateController.add(null);
      return true;
    }
    return false;
  }
}
