import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'package:torrent/src/agent/bt_agent.dart';
import 'package:torrent/src/announce/bt_announce.dart';
import 'package:torrent/src/bt_logger.dart';
import 'package:torrent/src/metainfo/bt_info.dart';
import 'package:torrent/src/peer/bt_bitfield.dart';
import 'package:torrent/src/peer/bt_peer.dart';
import 'package:torrent/src/peer/bt_peer_half.dart';
import 'package:torrent/src/peer/bt_pex.dart';
import 'package:torrent/src/piece/bt_block.dart';
import 'package:torrent/src/piece/bt_piece.dart';
import 'package:torrent/src/socket/bt_socket.dart';
import 'package:torrent/src/storage/bt_storage.dart';
import 'package:torrent/src/storage/bt_storage_disk.dart';
import 'package:torrent/src/torrent/bt_request.dart';
import 'package:torrent/src/tracker/bt_tracker.dart';
import 'package:torrent/src/peer/protocol/message.dart';

typedef dynamic localVerifyCallback(int verified);

class BtTorrent {
  BtTorrent({
    this.agent,
    this.info,
  }) {
    if (info.announceList != null) {
      for (var tier in info.announceList) {
        if (tier.isNotEmpty) {
          addTracker(tier.first);
        }
      }
    } else {
      addTracker(info.announce);
    }

    if (info.metaInfo.lengthInBytes != null) {
      _size = info.metaInfo.lengthInBytes;
    } else {
      _size = 0;
      for (var file in info.metaInfo.files) {
        _size += file.length;
      }
    }

    _blockSize = math.min(
      defaultBlockSize,
      info.metaInfo.pieceLengthInBytes,
    );
    _blockCount = (_size / _blockSize).ceil();

    _pieceSize = info.metaInfo.pieceLengthInBytes;
    _pieceCount = info.metaInfo.pieces.length;

    _lastPieceSize = _size % _pieceSize;
    _lastBlockSize = _size % _blockSize;

    if (_lastPieceSize == 0) _lastPieceSize = _pieceSize;
    if (_lastBlockSize == 0) _lastBlockSize = _blockSize;

    bitfield.grow(_pieceCount);
    blockBitfield.grow(_blockCount);

    storage = BtDiskBucket('.').open(info.metaInfo);
  }

  int _size;
  int get size => _size;

  static const defaultBlockSize = 2 << 14;
  int _blockSize;
  int _blockCount;
  int get blockSize => _blockSize;
  int get blockCount => _blockCount;

  int _pieceSize;
  int _pieceCount;
  int get pieceSize => _pieceSize;
  int get pieceCount => _pieceCount;

  int _lastPieceSize;
  int _lastBlockSize;
  int get lastPieceSize => _lastPieceSize;
  int get lastBlockSize => _lastBlockSize;

  BtAgentCore agent;
  BtInfo info;

  final trackers = <String, BtTracker>{};

  Timer _updateRequestTimer;
  final _trackerSubscriptions = <String, StreamSubscription>{};

  final _pex = <String>{};
  final _peers = <String, BtPeer>{};

  final _blocksPending = <int, BtBlock>{};
  final _blocksRequesting = <int, BtRequest>{};

  final bitfield = BtBitfield.empty();
  final blockBitfield = BtBitfield.empty();

  BtStorage storage;

  void start() {
    if (_updateRequestTimer != null) {
      return;
    }
    const updateRequestDuration = Duration(milliseconds: 500);
    _updateRequestTimer = Timer.periodic(updateRequestDuration, (_) {
      updateTimeout();
      updateRequests();
    });
  }

  void have(int piece, [int to]) {
    assert(isValidPieceIndex(piece));

    final end = to ?? piece;
    for (var index = piece; index <= end; index++) {
      bitfield.set(index);
      for (var block in BtPiece(index).blocks(this)) {
        _blocksPending.remove(block.index(this));
        blockBitfield.set(block.index(this));
      }
      for (var peer in _peers.values) {
        peer.sendHave(piece);
      }
    }
  }

  void haveAll() {
    // ...
  }

  void downloadAll() {
    download(0, pieceCount - 1);
  }

  void download(int from, [int to]) {
    assert(from >= 0);
    assert(to == null || to < pieceCount);

    final end = to ?? from;
    for (var index = from; index <= end; index++) {
      if (bitfield.get(index)) {
        continue;
      }
      final blocks = BtPiece(index).blocks(this);
      for (var block in blocks) {
        if (!blockBitfield.get(block.index(this))) {
          _blocksPending[block.index(this)] = block;
        }
      }
    }

    start();
  }

  double percent() {
    return bitfield.trueCount / pieceCount;
  }

  List<int> absentPieces() {
    final result = <int>[];
    for (var index = 0; index < pieceCount; index++) {
      if (!bitfield.get(index)) {
        result.add(index);
      }
    }
    return result;
  }

  bool addTracker(String url, [bool start = false]) {
    if (trackers.containsKey(url)) {
      BtLog.fine('Duplicated tracker: $url');
      return false;
    }

    final tracker = BtTracker(
      url: url,
      torrent: this,
    );
    trackers[url] = tracker;
    if (start) {
      tracker.start();
    }
    final listen = tracker.onPeer.listen(addPeer);
    _trackerSubscriptions[url] = listen;

    BtLog.fine('Tracker added: $url');
    return true;
  }

  bool removeTracker(String url) {
    if (!trackers.containsKey(url)) {
      return false;
    }

    final tracker = trackers[url];
    tracker.stop();
    trackers.remove(url);
    _trackerSubscriptions[url].cancel();
    _trackerSubscriptions.remove(url);
    return true;
  }

  startAllTrackers() {
    for (var tracker in trackers.values) {
      tracker.start();
    }
  }

  stopAllTrackers() {
    for (var tracker in trackers.values) {
      tracker.stop();
    }
  }

  addPeer(BtPex pex) async {
    if (_pex.contains(pex.toString())) {
      BtLog.finer('Duplicated peer: $pex');
      return;
    }
    _pex.add(pex.toString());
    BtLog.finer('Got peer: $pex');
    Socket socket;
    try {
      socket = await Socket.connect(pex.addr, pex.port);
    } catch (e) {
      BtLog.finer('Tcp connection error: $e');
      return;
    }

    final peer = await BtPeerHalf(BtSocket(socket)).handshake(this);
    _peers[peer.toString()] = peer;
    // peer.sendBitfield(bitfield);
    peer.startKeepAlive();
    peer.interested();

    peer.on<Interested>().listen((_) {
      // peer.unchoke();
    });

    peer.on<Piece>().listen((piece) async {
      final index = BtBlock.fromBlock(piece).index(this);
      _blocksPending.remove(index);
      _blocksRequesting.remove(index);
      blockBitfield.set(index);
      final offset = piece.index * pieceSize + piece.begin;
      print(piece.data.sublist(0, 20));
      print(offset);
      storage.write(piece.data, offset);

      if (isPieceCompleted(piece.index)) {
        BtLog.fine('$this: piece #${piece.index} completed');
        if (await verifyPiece(piece.index)) {
          BtLog.fine('$this: piece #${piece.index} verified');
          have(piece.index);
        } else {
          BtLog.warning('$this: currupted piece #${piece.index}');
        }
      }
    });

    BtLog.fine('$this: Connected to peer: $peer');
  }

  bool isPieceCompleted(int index) {
    for (var block in BtPiece(index).blocks(this)) {
      if (!blockBitfield.get(block.index(this))) {
        return false;
      }
    }
    return true;
  }

  void verifyLocalData([localVerifyCallback callback]) async {
    for (var index = 0; index < pieceCount; index++) {
      final verified = await verifyPiece(index);
      if (verified) {
        bitfield.set(index);
      }

      if (callback != null) {
        final abort = callback(index);
        if (abort == true) return;
      }
    }
  }

  Future<bool> verifyPiece(int index) async {
    assert(isValidPieceIndex(index));

    final data = await storage.read(
      getPieceSize(index),
      pieceOffset(index),
    );

    final hash = getPieceHash(index);
    final resultHash = sha1.convert(data).bytes;

    for (var i = 0; i < hash.length; i++) {
      if (hash[i] != resultHash[i]) {
        return false;
      }
    }
    return true;
  }

  int pieceOffset(int index) {
    assert(isValidPieceIndex(index));

    return index * pieceSize;
  }

  int getPieceSize(int index) {
    assert(isValidPieceIndex(index));

    return isLastPiece(index) ? lastPieceSize : pieceSize;
  }

  List<int> getPieceHash(int index) {
    assert(isValidPieceIndex(index));

    return info.metaInfo.pieces[index];
  }

  bool isLastPiece(int index) {
    assert(isValidPieceIndex(index));

    return index == pieceCount - 1;
  }

  bool isValidPieceIndex(int index) {
    return index >= 0 && index < pieceCount;
  }

  void updateRequests() {
    for (var peer in _peers.values) {
      if (peer.isChoking) {
        continue;
      }
      final next = nextRequestsForPeer(peer);
      for (var block in next) {
        peer.sendRequest(block);
        _blocksPending.remove(block.index(this));
        _blocksRequesting[block.index(this)] = BtRequest(
          sentAt: DateTime.now(),
          block: block,
          peer: peer,
        );
      }
    }
  }

  void updateTimeout() {
    final timeoutList = <BtRequest>[];

    for (var request in _blocksRequesting.values) {
      const timeout = Duration(seconds: 10);
      if (DateTime.now().difference(request.sentAt) > timeout) {
        timeoutList.add(request);
      }
    }

    for (var request in timeoutList) {
      final index = request.block.index(this);
      request.peer.pendingBlocks--;
      _blocksRequesting.remove(index);
      _blocksPending[index] = request.block;
    }
  }

  List<BtBlock> nextRequestsForPeer(BtPeer peer) {
    final result = <BtBlock>[];
    final want = peer.wireSize - peer.pendingBlocks;
    for (var item in _blocksPending.entries) {
      final index = item.key;
      final block = item.value;
      if (result.length >= want) {
        break;
      }
      if (blockBitfield.get(index)) {
        continue;
      }
      if (peer.bitfield.get(block.piece)) {
        result.add(block);
      }
    }
    return result;
  }

  void seed(bool enabled) {
    // ...
  }

  BtAnnounce genAnnounce() {
    return BtAnnounce(
      infoHash: info.infoHash,
      peerId: agent.id,
      downloaded: 0,
      left: 0,
      uploaded: 0,
      port: 12306,
    );
  }

  @override
  String toString() {
    final shortHash = hex.encode(info.infoHash).substring(0, 10);
    return '$runtimeType{$shortHash}';
  }
}
