class Quality extends Comparable {
  String quality;
  String url;

  static final qualities = {
    '4K UHD': 1,
    '1080 HD': 2,
    '720p': 3,
    '480p': 4,
  };

  Quality({
    this.quality = '',
    this.url = '',
  });

  Quality.fromJson(Map<String, dynamic> json) {
    quality = json['quality'] ?? '';
    url = json['url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'url': url,
    };
  }

  @override
  int compareTo(other) {
    return (Quality.qualities[quality] ?? 0).compareTo(
      Quality.qualities[other.quality] ?? 0,
    );
  }
}
