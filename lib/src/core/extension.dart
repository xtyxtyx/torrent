import 'dart:typed_data';
import 'package:convert/convert.dart';

import 'package:torrent/src/bencode/bencode.dart';

extension ListExt on List {
  Uint8List asUint8List() {
    return this is Uint8List ? this : Uint8List.fromList(this);
  }
}

extension IntExt on int {

}

extension NullAssert on Object {
  bool get isNull => this == null;
  bool get isNotNull => this != null;
}

extension ByteExt on Uint8List {
  Uint8List slice([int offsetInBytes = 0, int length]) {
    return this.buffer.asUint8List(offsetInBytes, length);
  }

  String asHex() {
    return hex.encode(this);
  }
}

extension MapToBenc on Map {
  List<int> toBenc() {
    return benc.encode(this);
  }
}