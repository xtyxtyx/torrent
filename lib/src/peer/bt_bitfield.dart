import 'dart:collection';
import 'dart:typed_data';

int byteLength(int bitLength) {
  return (bitLength / 8).ceil();
}

class BtBitfield {
  BtBitfield.empty([int length = 0]) : _buffer = Uint8List(byteLength(length));

  Uint8List _buffer;
  List<int> get data => _buffer;

  int _trueCount = 0;
  int get trueCount => _trueCount;

  void grow(int bitLength) {
    final byteLength = (bitLength / 8).ceil();
    if (_buffer.length >= byteLength) {
      return;
    } else {
      _buffer = Uint8List(byteLength)..setAll(0, _buffer);
    }
  }

  bool get(int index) {
    assert(index >= 0);

    grow(index);

    final byteIndex = index >> 3;
    assert(byteIndex >= 0, 'index can not be smaller than zero.');

    if (byteIndex > _buffer.length) {
      return false;
    }
    final bit = _buffer[byteIndex] & (128 >> (index % 8));
    return bit != 0;
  }

  void set(int index, [bool bit = true]) {
    assert(index >= 0);

    if (get(index) == bit) {
      return;
    }

    grow(index);

    final byteIndex = index >> 3;
    assert(byteIndex >= 0, 'index can not be smaller than zero.');

    if (bit) {
      _buffer[byteIndex] |= (128 >> (index % 8));
      _trueCount++;
    } else {
      _buffer[byteIndex] &= ~(128 >> (index % 8));
      _trueCount--;
    }
  }

  void setRange(int start, int end, bool bit) {
    for (var i = start; i < end; i++) {
      set(i, bit);
    }
  }

  void copy(List<int> data) {
    _buffer = Uint8List.fromList(data);
    _trueCount = 0;
    for (var i = 0; i < _buffer.length * 8; i++) {
      if (get(i)) {
        _trueCount++;
      }
    }
  }
}
