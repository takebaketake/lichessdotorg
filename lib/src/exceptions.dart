class LichessException implements Exception {
  final int statusCode;
  final String body;

  const LichessException(this.statusCode, this.body);

  @override
  String toString() => 'LichessException($statusCode): $body';
}
