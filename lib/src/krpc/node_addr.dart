import 'dart:io';
import 'dart:typed_data';

import 'package:torrent/src/core/extension.dart';
import 'package:torrent/src/core/helper.dart';

class NodeAddr {
  NodeAddr(this.ip, this.port);

  static Future<NodeAddr> lookup(String host, int port) async {
    final lookupResult = await InternetAddress.lookup(host);

    if (lookupResult == null) {
      return null;
    }

    return NodeAddr(lookupResult.first, port);
  }

  final InternetAddress ip;
  final int port;

  @override
  String toString() {
    return '${ip.address}:$port';
  }
}
