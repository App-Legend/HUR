class ApiConstants {
  static const String baseUrl = 'http://13.209.64.205';

  /// 서버가 내려주는 이미지 경로를 화면에 쓸 수 있는 전체 주소로 바꾼다.
  /// S3 주소(https://...)는 그대로 쓰고, 예전 형식의 상대경로(/uploads/..)만 서버 주소를 붙인다.
  static String imageUrl(Object? path) {
    final value = path?.toString() ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return '$baseUrl$value';
  }
}
