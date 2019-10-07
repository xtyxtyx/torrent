import 'dart:typed_data';

class PeerBitfield {
  PeerBitfield(List<int> data)
      : bytes = data is Uint8List ? data : Uint8List.fromList(data);

  final Uint8List bytes;

  bool get(int index) {
    final byteIndex = index >> 3;
    assert(byteIndex >= 0, 'index can not be smaller than zero.');
    assert(byteIndex < bytes.length,
        'index can not be greater than buffer length.');
    final bit = bytes[byteIndex] & (128 >> (index % 8));
    return bit != 0;
  }

  void set(int index, [bool bit = true]) {
    final byteIndex = index >> 3;
    assert(byteIndex >= 0, 'index can not be smaller than zero.');
    assert(byteIndex < bytes.length,
        'index can not be greater than buffer length.');
    if (bit) {
      bytes[byteIndex] |= (128 >> (index % 8));
    } else {
      bytes[byteIndex] &= ~(128 >> (index % 8));
    }
  }
}
