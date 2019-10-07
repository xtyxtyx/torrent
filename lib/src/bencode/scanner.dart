import 'dart:convert';

class Scanner {
  final List<int> _data;
  int _pos = 0;

  get _stringData => String.fromCharCodes(_data, _pos);
  get dataLength => _data.length;
  get pos => _pos;
  bool get atEOF => peekString() == null;

  Scanner(List<int> data) : _data = data;

  Scanner.fromString(String data) : _data = data.runes.toList();

  String takeString([int len = 1]) {
    final codes = take(len);
    if (codes == null) return null;
    try {
      return utf8.decode(codes);
    } catch (_) {
      return String.fromCharCodes(codes);
    }
  }

  List<int> take([int len = 1]) {
    final result = peek(len);
    if (result == null) {
      return null;
    }

    _pos += len;
    return result;
  }

  String peekString([int len = 1]) {
    final codes = peek(len);
    return codes != null ? String.fromCharCodes(codes) : null;
  }

  List<int> peek([int len = 1]) {
    if (_data.length < _pos + len) {
      return null;
    }

    final result = _data.sublist(_pos, _pos + len);
    return result;
  }

  String match(Pattern pattern) {
    final result = pattern.matchAsPrefix(_stringData);
    if (result == null) {
      return null;
    }
    return result.group(0);
  }

  bool matches(Pattern pattern) {
    final result = match(pattern);
    return result != null;
  }

  String expect(Pattern pattern) {
    final result = match(pattern);
    if (result == null) {
      throw '$pattern expected at $_pos';
    }
    _pos += result.length;
    return result;
  }

  void expectEOF() {
    if (!atEOF) {
      throw 'EOF expected at $_pos';
    }
  }

  int readInt() {
    int flag = 1;
    final digits = <String>[];
    if (matches('-')) {
      takeString();
      flag = -1;
    }
    while (matches(RegExp(r'[0-9]'))) {
      digits.add(takeString());
    }
    if (digits.isEmpty) {
      throw '<digit> expected at ${pos}';
    }
    return flag * int.parse(digits.join(''));
  }

  void reset() {
    _pos = 0;
  }
}
