import 'player_js.dart';

class Salt {
  static var abc = String.fromCharCodes([
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    97,
    98,
    99,
    100,
    101,
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    110,
    111,
    112,
    113,
    114,
    115,
    116,
    117,
    118,
    119,
    120,
    121,
    122
  ]);
  static final _keyStr = abc + '0123456789+/=';

  static String charAt(String s, int index) {
    if (s.length <= index) return '';
    return s[index];
  }

  static String d(String e) {
    var t = '';
    var n, r, i;
    var s, o, u, a;
    var f = 0;
    e = e.replaceAll(RegExp(r'[^A-Za-z0-9\+\/\=]'), '');
    while (f < e.length) {
      s = _keyStr.indexOf(charAt(e, f++));
      o = _keyStr.indexOf(charAt(e, f++));
      u = _keyStr.indexOf(charAt(e, f++));
      a = _keyStr.indexOf(charAt(e, f++));
      n = s << 2 | o >> 4;
      r = (o & 15) << 4 | u >> 2;
      i = (u & 3) << 6 | a;
      t = t + PlayerJS.dechar(n);
      if (u != 64) {
        t = t + PlayerJS.dechar(r);
      }
      if (a != 64) {
        t = t + PlayerJS.dechar(i);
      }
    }
    t = _ud(t);
    return t;
  }

  static String _ud(String e) {
    var t = '';
    var n = 0;
    var r = 0;
    var c1 = 0;
    var c2 = 0;
    while (n < e.length) {
      r = e.codeUnitAt(n);
      if (r < 128) {
        t += PlayerJS.dechar(r);
        n++;
      } else if (r > 191 && r < 224) {
        c2 = e.codeUnitAt(n + 1);
        t += PlayerJS.dechar((r & 31) << 6 | c2 & 63);
        n += 2;
      } else {
        c2 = e.codeUnitAt(n + 1);
        c1 = e.codeUnitAt(n + 2); //c3
        t += PlayerJS.dechar((r & 15) << 12 | (c2 & 63) << 6 | c1 & 63); //c3
        n += 3;
      }
    }
    return t;
  }
}