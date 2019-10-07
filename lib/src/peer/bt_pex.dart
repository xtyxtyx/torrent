import 'dart:io';

import 'dart:typed_data';

import 'package:torrent/src/util/ipv4.dart';

class BtPex {
  BtPex({
    this.addr,
    this.port,
  });

  BtPex.fromCompact(List<int> compact) {
    final buffer = Uint8List.fromList(compact).buffer.asByteData();
    final ip = buffer.getUint32(0);
    final port = buffer.getUint16(4);

    this.addr = InternetAddress(IPv4.fromInt(ip).toString());
    this.port = port;
  }

  InternetAddress addr;
  int port;

  @override
  String toString() {
    return '${this.runtimeType}{${addr.address}:$port}';
  }
} 