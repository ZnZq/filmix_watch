import 'package:http/http.dart' as http;

import 'package:filesize/filesize.dart';

class Quality extends Comparable {
  String quality;
  String url;
  int _size;

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

  Future<String> getSize() async {
    if (_size == 0) {
      var resp = await http.head(url);
      _size = int.parse(resp?.headers['content-length'] ?? '0');
    }

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
