import 'dart:typed_data';

class ReservedBytes {
  final _reserved = Uint8List(8);

  List<int> get bytes => _reserved;

  void allowFast() {
    _reserved[7] |= 0x04;
  }
}