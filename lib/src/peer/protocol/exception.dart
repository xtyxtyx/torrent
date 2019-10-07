class ParseException implements Exception {
  String detail;
  ParseException(this.detail);
  @override
  String toString() {
    return 'Parse failed: $detail';
  }
}

class BadMessageException implements Exception {
  String detail;
  BadMessageException(this.detail);
  @override
  String toString() {
    return 'Bad message: $detail';
  }
}