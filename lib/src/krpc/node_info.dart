import 'dart:io';
import 'dart:typed_data';

import 'package:torrent/src/core/extension.dart';
import 'package:torrent/src/core/helper.dart';
import 'package:torrent/src/krpc/node_addr.dart';

class NodeInfo {
  NodeInfo(this.id, this.addr);

  static NodeInfo parseCompact(Uint8List compact) {
    final id = compact.slice(0, 20);
    final ip = decodeIpv4(compact.slice(20, 24));
    final bytes = compact.asUint8List().buffer.asByteData();
    final port = bytes.getUint16(24);
    return NodeInfo(id, NodeAddr(InternetAddress(ip), port));
  }

  static Iterable<NodeInfo> parseCompactList(Uint8List compact) sync* {
    const bytesPerNode = 26;
    if (compact.length % bytesPerNode != 0) {
      return;
    }

    for (var i = 0; i < compact.length ~/ bytesPerNode; i++) {
      final offset = i * 26;
      print(offset);
      final id = compact.slice(offset, 20);
      final ip = decodeIpv4(compact.slice(offset + 20, 4));
      final bytes = compact.asUint8List().buffer.asByteData();
      final port = bytes.getUint16(offset + 24);
      yield NodeInfo(id, NodeAddr(InternetAddress(ip), port));
    }
  }

  final Uint8List id;
  final NodeAddr addr;

  @override
  String toString() {
    return '${id.asHex()}($addr)';
  }
}