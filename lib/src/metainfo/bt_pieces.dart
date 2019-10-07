class BtPieces {
  BtPieces(this._data) : count = (_data.length / pieceLength).ceil();

  static const pieceLength = 20;

  final List<int> _data;
  final count;

  Iterable<List<int>> groups() sync* {
    int current = 1;
    while (true) {
      final offset = (current - 1) * pieceLength;
      yield _data.sublist(offset, offset + pieceLength);

      final isLast = current == count;
      if (isLast) {
        break;
      } else {
        current++;
      }
    }
  }
}
