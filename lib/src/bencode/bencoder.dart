import 'dart:convert';

import 'dart:typed_data';

final bEncoder = BEncoder._();

class BEncoder extends Converter<dynamic, List<int>> {
  BEncoder._();

  /// `convert` converts dart object to bencoded bytes
  ///
  /// Note that Strings are encoded in utf8. To encode raw bytes,
  /// please use Uint8List. More details in README and bencode_example.dart.
  List<int> convert(dynamic object) {
    if (object is String) {
      return _encodeUtf8String(object);
    }
    if (object is int) {
      return _encodeInteger(object);
    }
    if (object is Uint8List) {
      return _encodeString(object);
    }
    if (object is List) {
      return _encodeList(object);
    }
    if (object is Map) {
      return _encodeDictionary(object);
    }

    throw 'unsupported object type ${object.runtimeType}';
  }

  List<int> _encodeUtf8String(String str) {
    final data = utf8.encode(str);
    final length = ascii.encode(data.length.toString());
    const comma = 58; // ascii code of `:`
    return length + [comma] + data;
  }

  List<int> _encodeString(List<int> data) {
    final length = ascii.encode(data.length.toString());
    const comma = 58; // ascii code of `:`
    return length + [comma] + data;
  }

  List<int> _encodeInteger(int i) {
    return ascii.encode('i${i.toString()}e');
  }

  List<int> _encodeList(List<dynamic> list) {
    final result = <int>[];
    const i = 108; // ascii code of `l`
    const e = 101; // ascii code of `e`
    result.add(i);
    for (var item in list) {
      result.addAll(convert(item));
    }
    result.add(e);
    return result;
  }

  List<int> _encodeDictionary(Map<String, dynamic> dict) {
    final result = <int>[];
    const d = 100; // ascii code of `d`
    const e = 101; // ascii code of `e`
    result.add(d);
    for (var item in dict.entries) {
      result.addAll(convert(item.key));
      result.addAll(convert(item.value));
    }
    result.add(e);
    return result;
  }
}
