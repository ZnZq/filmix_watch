import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

import 'package:filesize/filesize.dart';

class Quality extends Comparable {
  String quality;
  String url;
  int _size;

  static final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectStatus;

  static final qualities = {
    '480p': 1,
    '720p': 2,
    '1080 HD': 3,
    '4K UHD': 4,
  };

  Quality({
    this.quality = '',
    this.url = '',
  });

  final regexCode = RegExp(r's\/(?<code>\w+)\/');

  Future<String> getSize() async {
    try {
      var status = await _connectivity.checkConnectivity();
      if (status != _connectStatus) {
        _connectStatus = status;
        _size = 0;
      }

      if (_size == 0) {
        var resp = await http.head(url);
        _size = int.parse(resp?.headers['content-length'] ?? '0');

        if (_size == 0) {
          var code = regexCode.firstMatch(url)?.namedGroup('code');
          var newCode = code == 'b067090d21fbb988502675ef79745ff6b1e825'
              ? '2e2ffdec9fd12ab24985961f88849e31410d0c'
              : 'b067090d21fbb988502675ef79745ff6b1e825';
          var newUrl =
              url.replaceFirstMapped(regexCode, (match) => 's/$newCode/');

          var resp = await http.head(newUrl);
          _size = int.parse(resp?.headers['content-length'] ?? '0');

          url = newUrl;
        }
      }
    } catch (e) {}

    return filesize(_size);
  }

  Quality.fromJson(Map<String, dynamic> json) {
    quality = json['quality'] ?? '';
    url = json['url'] ?? '';
    _size = json['size'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'url': url,
      'size': _size,
    };
  }

  @override
  int compareTo(other) {
    return (Quality.qualities[other.quality] ?? 0).compareTo(
      Quality.qualities[quality] ?? 0,
    );
  }
}
