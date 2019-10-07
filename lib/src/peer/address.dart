import 'dart:typed_data';

import 'package:torrent/src/util/ipv4.dart';

class PeerAddress {
  final String host;
  final int port;

  PeerAddress(this.host, this.port);

  factory PeerAddress.fromCompact(List<int> data) {
    final buffer = Uint8List.fromList(data).buffer.asByteData();
    final ip = buffer.getUint32(0);
    final port = buffer.getUint16(4);
    return PeerAddress(IPv4.fromInt(ip).toString(), port);
  }

  @override
  String toString() {
    return '$host:$port';
  }

  operator ==(that) =>
      that is PeerAddress && that.host == this.host && that.port == this.port;

  @override
  int get hashCode => toString().hashCode;
}
