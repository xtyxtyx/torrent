import 'package:torrent/src/peer/protocol/message.dart';
import 'package:torrent/src/torrent/bt_torrent.dart';

class BtBlock {
  BtBlock({
    this.piece,
    this.offset,
    this.length,
  });

  BtBlock.fromBlock(Piece piece) {
    this.piece = piece.index;
    this.offset = piece.begin;
    this.length = piece.data.length;
  }

  int piece;
  int offset;
  int length;

  int index(BtTorrent torrent) {
    int index = 0;
    index += piece * (torrent.pieceSize ~/ torrent.blockSize);
    index += offset ~/ torrent.blockSize;
    return index;
  }
}
