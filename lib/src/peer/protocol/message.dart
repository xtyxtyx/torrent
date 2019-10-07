import 'dart:typed_data';

import 'package:torrent/src/hash.dart';
import 'package:torrent/src/peer/protocol/exception.dart';
import 'package:torrent/src/peer/protocol/reserved.dart';

abstract class Message {
  List<int> encode();

  factory Message.decode(List<int> data) {
    final buffer = Uint8List.fromList(data).buffer.asByteData();
    final length = buffer.getUint32(0);
    if (data.length - 4 != length) {
      throw BadMessageException(
          'length = $length, actual length: ${data.length - 4}');
    }
    if (length == 0) return KeepAlive();
    final id = buffer.getUint8(4);
    switch (id) {
      case 0:
        return Choke();
      case 1:
        return Unchoke();
      case 2:
        return Interested();
      case 3:
        return NotInterested();
      case 4:
        final index = buffer.getUint32(5);
        return Have()..index = index;
      case 5:
        return BitField()..data = data.sublist(4 + 1);
      case 6:
        final index = buffer.getUint32(5);
        final begin = buffer.getUint32(9);
        final length = buffer.getUint32(13);
        return Request()
          ..index = index
          ..begin = begin
          ..length = length;
      case 7:
        final index = buffer.getUint32(5);
        final begin = buffer.getUint32(9);
        return Piece()
          ..index = index
          ..begin = begin
          ..data = data.sublist(13);
      case 8:
        final index = buffer.getUint32(5);
        final begin = buffer.getUint32(9);
        final length = buffer.getUint32(13);
        return Cancel()
          ..index = index
          ..begin = begin
          ..length = length;
      case 0x0E:
        return HaveAll();
      case 0x0F:
        return HaveNone();
      case 0x0D:
        final index = buffer.getUint32(5);
        return SuggestPiece()..index = index;
      case 0x10:
        final index = buffer.getUint32(5);
        final begin = buffer.getUint32(9);
        final length = buffer.getUint32(13);
        return RejectRequest()
          ..index = index
          ..begin = begin
          ..length = length;
      case 0x11:
        final index = buffer.getUint32(5);
        return AllowedFast()..index = index;
      default:
        throw ParseException('length = $length, id = $id');
    }
  }
}

abstract class EmptyMessage implements Message {
  int get id;

  List<int> encode() {
    final buffer = ByteData(5);
    buffer.setUint32(0, 1); // length
    buffer.setUint8(4, id); // id
    return buffer.buffer.asUint8List();
  }
}

abstract class IndexMessage implements Message {
  int get id;
  int get index;

  List<int> encode() {
    final buffer = ByteData(9);
    buffer.setUint32(0, 5); // length
    buffer.setUint8(4, id); // id
    buffer.setUint8(5, index); // index
    return buffer.buffer.asUint8List();
  }
}

abstract class BlockMessage implements Message {
  int get id;
  int get index;
  int get begin;
  int get length;

  List<int> encode() {
    final buffer = ByteData(17);
    buffer.setUint32(0, 13); // length
    buffer.setUint8(4, id); // id
    buffer.setUint32(5, index);
    buffer.setUint32(9, begin);
    buffer.setUint32(13, length);
    return buffer.buffer.asUint8List();
  }
}

class Handshake implements Message {
  Handshake({
    this.infoHash,
    this.peerId,
    this.reserved,
  }) {
    reserved = reserved ?? Uint8List(8);
  }

  static const length = 68;
  static const magic = 19;
  static final protocol = 'BitTorrent protocol'.runes.toList();

  List<int> infoHash;
  List<int> peerId;
  List<int> reserved;

  List<int> encode() {
    final data = Uint8List(68);
    data.buffer.asByteData().setUint8(0, magic);
    data.setAll(1, protocol);
    data.setAll(20, reserved);
    data.setAll(28, infoHash);
    data.setAll(48, peerId);
    return data;
  }

  factory Handshake.decode(List<int> bytes) => _decode(bytes);

  static Handshake _decode(List<int> bytes) {
    assert(bytes.length == 68);
    final data = Uint8List.fromList(bytes);
    final magic = data.buffer.asByteData().getUint8(0);
    final protocol = data.getRange(1, 20);
    assert(magic == Handshake.magic);
    assert(protocol == Handshake.protocol);
    final reserved = data.getRange(20, 28).toList();
    final infoHash = data.getRange(28, 48).toList();
    final peerId = data.getRange(48, 68).toList();
    return Handshake()
      ..infoHash = infoHash
      ..peerId = peerId
      ..reserved = reserved;
  }

  String toString() =>
      'Handshake{infoHash=$infoHash, peerId=$peerId, reserved=$reserved}';
}

class KeepAlive implements Message {
  List<int> encode() => Uint8List(4);
  String toString() => 'KeepAlive{}';
}

class Choke with EmptyMessage {
  final int id = 0;
  String toString() => 'Chock{}';
}

class Unchoke with EmptyMessage {
  final int id = 1;
  String toString() => 'Unchock{}';
}

class Interested with EmptyMessage {
  final int id = 2;
  String toString() => 'Interested{}';
}

class NotInterested with EmptyMessage {
  final int id = 3;
  String toString() => 'NotInterested{}';
}

class Have implements Message {
  final int id = 4;
  int index;

  List<int> encode() {
    final buffer = ByteData(9);
    buffer.setUint32(0, 5); // length
    buffer.setUint8(4, id); // id
    buffer.setUint32(5, index);
    return buffer.buffer.asUint8List();
  }

  String toString() => 'Have{index=$index}';
}

class BitField implements Message {
  BitField({
    this.data,
  });

  final int id = 5;
  List<int> data;

  List<int> encode() {
    final bytes = ByteData(4 + 1 + data.length);
    bytes.setUint32(0, 1 + data.length); // length
    bytes.setUint8(4, id); // id
    bytes.buffer.asUint8List().setAll(5, data);
    return bytes.buffer.asUint8List();
  }

  String toString() {
    const max_display = 5;
    final tooLong = data.length > max_display;
    final displayData = tooLong ? data.sublist(0, max_display) : data;
    final suffix = tooLong ? '...' : '';
    return 'BitField{length=${data.length}, data=${displayData.join(', ')} $suffix}';
  }
}

class Request with BlockMessage {
  Request({
    this.index,
    this.begin,
    this.length
  });
  
  final int id = 6;
  int index;
  int begin;
  int length;

  String toString() => 'Request{$index:$begin:$length}';
}

class Piece implements Message {
  final int id = 7;
  int index;
  int begin;
  List<int> data;

  List<int> encode() {
    final length = 1 + 8 + data.length;
    final buffer = ByteData(4 + length);
    buffer.setUint32(0, length); // length
    buffer.setUint8(4, id); // id
    buffer.setUint32(5, index);
    buffer.setUint32(9, begin);
    final list = buffer.buffer.asUint8List();
    list.setAll(13, data);
    return list;
  }

  String toString() => 'Piece{$index:$begin:${data.length}}';
}

class Cancel with BlockMessage {
  final int id = 8;
  int index;
  int begin;
  int length;

  String toString() => 'Cancel{$index:$begin:$length}';
}

class HaveAll with EmptyMessage {
  final int id = 0x0E;
  String toString() => 'HaveAll{}';
}

class HaveNone with EmptyMessage {
  final int id = 0x0F;
  String toString() => 'HaveNone{}';
}

class SuggestPiece with IndexMessage {
  final int id = 0x0D;
  int index;

  String toString() => 'SuggestPiece{$index}';
}

class RejectRequest with BlockMessage {
  final int id = 0x10;
  int index;
  int begin;
  int length;

  String toString() => 'RejectRequest{$index:$begin:$length}';
}

class AllowedFast with IndexMessage {
  final int id = 0x11;
  int index;

  String toString() => 'AllowedFast{$index}';
}
