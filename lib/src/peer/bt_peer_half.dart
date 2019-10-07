import 'dart:async';
import 'dart:io';

import 'package:torrent/src/bt_logger.dart';
import 'package:torrent/src/peer/bt_peer.dart';
import 'package:torrent/src/peer/protocol/message.dart';
import 'package:torrent/src/socket/bt_socket.dart';
import 'package:torrent/src/torrent/bt_torrent.dart';
import 'package:torrent/src/util/byte_view.dart';

const btHandshakeLength = 68;

class BtPeerHalf {
  BtPeerHalf(this._socket) {
    _subscription = _socket.onData.listen(_onData);
  }

  final _buffer = <int>[];
  final _peer = Completer<BtPeer>();

  BtSocket _socket;
  StreamSubscription _subscription;

  void _onData(List<int> data) {
    BtLog.finest(data);
    _buffer.addAll(data);
    if (_buffer.length < btHandshakeLength) {
      return;
    }

    _subscription.cancel();
    final handshakeData = ByteView(_buffer).view(
      length: Handshake.length,
    );
    final handshake = Handshake.decode(handshakeData);

    final otherBytes = ByteView(_buffer).view(
      offset: Handshake.length,
    );
    final peer = BtPeer(id: handshake.peerId);
    peer.feedData(otherBytes);
    peer.attachSocket(_socket);
    _peer.complete(peer);
  }

  Future reject() {
    return _socket.close();
  }

  Future<BtPeer> handshake(BtTorrent torrent) {
    final myHandshake = Handshake(
      peerId: torrent.agent.id,
      infoHash: torrent.info.infoHash,
    );
    _socket.add(myHandshake.encode());
    return _peer.future;
  }
}
