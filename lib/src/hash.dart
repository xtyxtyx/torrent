import 'dart:collection';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';

import 'utils.dart';

abstract class HashBase extends ListBase<int> {
  final Uint8List bytes;
  final int length = 20;

  HashBase(this.bytes) : assert(bytes.length % 20 == 0);
  HashBase.empty() : bytes = Uint8List(20);
  HashBase.fromList(List<int> bytes) : bytes = Uint8List.fromList(bytes);

  int operator [](int index) => bytes[index];
  void operator []=(int index, int value) => bytes[index] = value;
  set length(_) => throw 'operation not supported';

  String toHex() => hex.encode(bytes);

  String toUrl() => percent.encode(bytes);

  String toBase32() => base32.encode(bytes);

  @override
  String toString() => toHex();

  @override
  operator ==(Object that) =>
      that is HashBase && ListEquality().equals(this.bytes, that.bytes);

  @override
  int get hashCode => toString().hashCode;
}

class Hash extends HashBase {
  Hash(Uint8List bytes) : super(bytes);
  Hash.fromList(List<int> bytes) : super(Uint8List.fromList(bytes));
  Hash.random() : super.fromList(randomBytes(20));
  Hash.randomWithPrefix(List<int> prefix)
      : super.fromList(prefix + randomBytes(20 - prefix.length));

  Hash xor(Hash another) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = this[i] ^ another[i];
    }
    return Hash.fromList(bytes);
  }
}
