import 'dart:io';
import 'dart:math';

import 'dart:typed_data';

List<int> randomBytes(int length) {
  assert(length >= 0);
  final result = <int>[];
  final generator = Random.secure();
  for (var i = 0; i < length; i++) {
    result.add(generator.nextInt(255));
  }
  return result;
}

List<List<T>> splitList<T>(List<T> list, int piece_len) {
  final result = <List<T>>[];
  for (var i = 0; i < list.length; i += piece_len) {
    final item = list.sublist(i, i + piece_len);
    result.add(item);
  }
  return result;
}

List<T> combineList<T>(List<List<T>> list) {
  final result = <T>[];
  for (var item in list) {
    result.addAll(item);
  }
  return result;
}

int secondsSinceEpoch(DateTime time) {
  return (time.millisecondsSinceEpoch / 1000).round();
}

Future<List<T>> scanDirectoryFor<T>(Directory dir) async {
  final result = await dir.list(recursive: true).toList();
  result.retainWhere((e) => e is T);
  return List<T>.from(result);
}

String parseIPv4(int ip) {
  final buffer = ByteData(32);
  buffer.setUint32(0, ip);
  final part1 = buffer.getUint8(0);
  final part2 = buffer.getUint8(1);
  final part3 = buffer.getUint8(2);
  final part4 = buffer.getUint8(3);
  return '$part1.$part2.$part3.$part4';
}