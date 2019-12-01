import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:torrent/src/bencode/bencode.dart';
import 'package:torrent/src/krpc/krpc.dart';
import 'package:torrent/src/krpc/node_addr.dart';
import 'package:torrent/src/krpc/node_info.dart';

void main() async {
  final n = await NodeAddr.lookup('router.utorrent.com', 6881);

  final s = await KrpcSocket.bind('0.0.0.0', 6881);
  final r = await s.ping(n);
  print(r);

  final f = await s.findNode(n, s.id);
  print(NodeInfo.parseCompactList(f['r']['nodes']).toList());

}