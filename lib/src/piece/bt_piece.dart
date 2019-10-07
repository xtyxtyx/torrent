import 'package:torrent/src/piece/bt_block.dart';
import 'package:torrent/src/torrent/bt_torrent.dart';

class BtPiece {
  BtPiece(this.index);

  final int index;

  Iterable<BtBlock> blocks(BtTorrent torrent) sync* {
    final isLast = torrent.isLastPiece(index);
    final count = isLast
        ? (torrent.lastPieceSize / torrent.blockSize).ceil()
        : torrent.pieceSize ~/ torrent.blockSize;
    for (var i = 0; i < count; i++) {
      final isLastBlock = isLast && count == i + 1;
      final length = isLastBlock ? torrent.lastBlockSize : torrent.blockSize;
      yield BtBlock(
        piece: index,
        offset: i * torrent.blockSize,
        length: length,
      );
    }
  }
}
