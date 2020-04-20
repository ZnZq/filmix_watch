import 'package:http/http.dart';

import 'player_js.dart';

import 'package:http/http.dart' as http;

class Media {
  String url;
  List<String> plurls;
  var currentPlurl = 0;

  Media(this.url);

  Future<String> init() async {
    url = PlayerJS.trim(url);

    if (url.indexOf('#2') == 0) {
      url = PlayerJS.fd2(url);
    }

    if (url.isNotEmpty) {
      if (url.indexOf('#3') == 0 &&
          url.indexOf(PlayerJS.v['file3_separator']) > 0) {
        url = fd3(url);
      }
    }

    if (url.isNotEmpty) {
      if (url.indexOf('#0') == 0) {
        if (url.indexOf(PlayerJS.o['pltxt']) > 0) {
          url = fd0(url.replaceFirst(PlayerJS.o['pltxt'], '')) +
              PlayerJS.o['pltxt'];
        } else {
          url = fd0(url);
        }
      }
    }

    if (url.indexOf('.m3u') == url.length - 4 || url.indexOf('.txt') > 0) {
      plurls = url.split(' or ');
      return await playlistLoad();
    }
    return url;
  }

  Future<String> playlistLoad() async {
    url = plurls[currentPlurl];

    if (url.indexOf(PlayerJS.o['pltxt']) > 0) {
      url = url.replaceFirst(PlayerJS.o['pltxt'], '');
      PlayerJS.v['file'] = url;
    }

    var resp = await http.get(url);

    return playlist(resp);
  }

  String playlist(Response x) {
    if (x.body.isNotEmpty) {
      var y = x.body;
      if (y.indexOf('#2') == 0) {
        y = PlayerJS.fd2(y);
      }

      return y;
    }
    return '{}';
  }

  String fd0(s) {
    if (s.indexOf('.') == -1) {
      s = s.substr(1);
      var s2 = '';
      for (var i = 0; i < s.length; i += 3) {
        s2 += '%u0' + s.slice(i, i + 3);
      }
      s = PlayerJS.unescape(s2);
    }
    return s;
  }

  String fd3(x) => '';
}
