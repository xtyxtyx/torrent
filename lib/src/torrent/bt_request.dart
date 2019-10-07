import 'package:torrent/src/peer/bt_peer.dart';
import 'package:torrent/src/piece/bt_block.dart';

class BtRequest {
  BtRequest({
    this.block,
    this.sentAt,
    this.peer,
  });
  
  BtBlock block;
  DateTime sentAt;
  BtPeer peer;
} 