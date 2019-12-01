import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:torrent/src/bencode/bencode.dart';
import 'package:torrent/src/core/extension.dart';
import 'package:torrent/src/krpc/node_addr.dart';
import 'package:torrent/src/utils.dart';

class TransactionIdGenerator {
  int _id = 0;

  Uint8List next() {
    _id++;
    return Uint8List.fromList([
      (_id & 0xff00) >> 8,
      _id & 0xff,
    ]);
  }
}

tidToInt(List<int> tid) {
  return tid[0] << 8 + tid[1];
}

class KrpcSocket {
  KrpcSocket(this._socket) {
    _socket.listen(_onData);
  }

  static Future<KrpcSocket> bind(String addr, int port) async {
    final socket = await RawDatagramSocket.bind(addr, port);
    return KrpcSocket(socket);
  }

  final id = randomBytes(20).asUint8List();
  final RawDatagramSocket _socket;
  final _pending = <int, Completer>{};
  final _tid = TransactionIdGenerator();

  void _onData(e) {
    final data = _socket.receive()?.data;
    if (data == null) {
      return;
    }

    final resp = benc.decode(data);

    final key = tidToInt(resp['t']);
    final completer = _pending[key];
    if (completer == null) {
      return;
    }
    
    _pending.remove(key);
    completer.complete(resp);
  }

  Future<Map> _send(Map data, NodeAddr addr) async {
    final tid = _tid.next();
    final completer = Completer<Map>();
    _pending[tidToInt(tid)] = completer;

    data['t'] = tid;
    _socket.send(data.toBenc(), addr.ip, addr.port);

    return completer.future;
  }

  Future<Map> ping(NodeAddr addr) {

    final data = {
      'y': 'q',
      'q': 'ping',
      'a': {
        'id': id,
      }
    };

    return _send(data, addr);
  }

  Future<Map> findNode(NodeAddr addr, List<int> target) async {
    final data = {
      'y': 'q',
      'q': 'find_node',
      'a': {
        'id': id,
        'target': target.asUint8List(),
      }
    };

    return _send(data, addr);
  }
}
