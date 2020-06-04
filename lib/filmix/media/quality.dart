import 'package:connectivity/connectivity.dart';
import 'package:filmix_watch/settings.dart';
import 'package:http/http.dart' as http;

import 'package:filesize/filesize.dart';

class Quality extends Comparable {
  String quality;
  String url;
  String basicCode;
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
    this.basicCode = '',
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
        if (Settings.freeFullHD) {
          var codes = [...Settings.fullHDCodes.toList(), basicCode];

          for (var code in codes) {
            var newUrl =
                url.replaceFirstMapped(regexCode, (match) => 's/$code/');

            try {
              var resp = await http.head(newUrl);
              _size = int.parse(resp?.headers['content-length'] ?? '0');

              if (_size != 0) {
                url = newUrl;
                break;
              }
            } catch (e) {}
          }
        } else {
          var resp = await http.head(url);
          _size = int.parse(resp?.headers['content-length'] ?? '0');
        }
      }
    } catch (e) {}

    return filesize(_size);
  }

  Quality.fromJson(Map<String, dynamic> json) {
    quality = json['quality'] ?? '';
    url = json['url'] ?? '';
    basicCode = json['basicCode'] ?? '';
    _size = json['size'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'url': url,
      'basicCode': basicCode,
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
