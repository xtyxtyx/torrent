import 'dart:async';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:torrent/src/bt_logger.dart';
import 'package:torrent/src/peer/bt_bitfield.dart';
import 'package:torrent/src/peer/protocol/message.dart';
import 'package:torrent/src/peer/protocol/reader.dart';
import 'package:torrent/src/piece/bt_block.dart';
import 'package:torrent/src/socket/bt_socket.dart';

class BtPeer {
  BtPeer({
    this.id,
  }) {
    _updateWireSizeTimer = Timer.periodic(
      _updateWireSizeDuratoin,
      (_) => updateWireSize(),
    );
  }

  BtSocket _socket;
  StreamSubscription _socketSubscription;
  MessageReader _reader = MessageReader();
  Timer _keepAliveTimer;
  final _messageStreamController = StreamController<Message>.broadcast();

  List<int> id;
  BtBitfield bitfield = BtBitfield.empty();

  bool _amChoking = true;
  bool _isChoking = true;
  bool _amInterested = false;
  bool _isInterested = false;

  bool get amChoking => _amChoking;
  bool get isChoking => _isChoking;
  bool get amInterested => _amInterested;
  bool get isInterested => _isInterested;

  DateTime _lastActive;
  DateTime get lastActive => _lastActive;

  int _wireSize = 3;
  int get wireSize => _wireSize;

  int _pendingBlocks = 0;
  int get pendingBlocks => _pendingBlocks;
  set pendingBlocks(int value) => _pendingBlocks = value;

  static const _updateWireSizeDuratoin = Duration(milliseconds: 3000);
  Timer _updateWireSizeTimer;
  int _blocksReceivedLastTime = 0;

  void updateWireSize() {
    _wireSize = _blocksReceivedLastTime ~/
            (_updateWireSizeDuratoin.inMilliseconds / 1000) +
        3;
    _blocksReceivedLastTime = 0;
  }

  void attachSocket(BtSocket socket) {
    if (_socketSubscription != null) {
      _socketSubscription.cancel();
      _socketSubscription = null;
    }
    _socket = socket;
    _socket.onData.listen(feedData).onError(BtLog.finer);
  }

  void feedData(List<int> data) {
    _reader.add(data);
    final message = _reader.tryConsume();
    if (message == null) {
      return;
    }
    _onMessage(message);
  }

  void _onMessage(Message message) {
    BtLog.finer('$this -> $message');
    switch (message.runtimeType) {
      case KeepAlive:
        return _onKeepAlive();
      case Choke:
        return _onChoke(message);
      case Unchoke:
        return _onUnchoke(message);
      case Interested:
        return _onInterested(message);
      case NotInterested:
        return _onNotInterested(message);
      case Have:
        return _onHave(message);
      case BitField:
        return _onBitField(message);
      case Request:
        return _onRequest(message);
      case Piece:
        return _onPiece(message);
      case Cancel:
        return _onCancel(message);
      default:
        fire(message);
    }
  }

  Stream<T> on<T extends Message>() {
    return _messageStreamController.stream.where((m) => m is T).cast<T>();
  }

  fire(Message message) {
    _messageStreamController.add(message);
  }

  void _onKeepAlive() {
    touch();
  }

  void _onChoke(message) {
    _isChoking = true;
    fire(message);
  }

  void _onUnchoke(message) {
    _isChoking = false;
    fire(message);
  }

  void _onInterested(message) {
    _isInterested = true;
    fire(message);
  }

  void _onNotInterested(message) {
    _isInterested = false;
    fire(message);
  }

  void _onHave(Have message) {
    if (bitfield == null) return;
    bitfield.set(message.index, true);
    fire(message);
  }

  void _onBitField(BitField message) {
    bitfield.copy(message.data);
    fire(message);
  }

  void _onRequest(Request message) {
    if (_amChoking) return;
    // _peerRequests.add(message);
    fire(message);
  }

  void _onPiece(Piece message) {
    // _requests.pull(
    //   message.index,
    //   message.begin,
    //   message.data.length,
    // );
    _pendingBlocks--;
    _blocksReceivedLastTime++;
    fire(message);
  }

  void _onCancel(Cancel message) {
    // _peerRequests.pull(
    //   message.index,
    //   message.begin,
    //   message.length,
    // );
    fire(message);
  }

  void startKeepAlive() {
    if (_keepAliveTimer != null) {
      return;
    }
    _keepAliveTimer = Timer.periodic(
      Duration(seconds: 20),
      (_) => sendKeepAlive(),
    );
  }

  void touch() {
    _lastActive = DateTime.now();
  }

  void send(Message message) {
    BtLog.finer('$this <- $message');
    BtLog.finest('$this <- ${message.encode()}');
    touch();
    _socket.add(message.encode());
  }

  void sendBitfield(BtBitfield bitfield) {
    final msg = BitField(data: bitfield.data);
    send(msg);
  }

  sendKeepAlive() {
    send(KeepAlive());
  }

  choke() {
    if (_amChoking) return;
    _amChoking = true;
    send(Choke());
  }

  unchoke() {
    if (!_amChoking) return;
    _amChoking = false;
    send(Unchoke());
  }

  interested() {
    if (_amInterested) return;
    _amInterested = true;
    send(Interested());
  }

  notinterested() {
    if (!_amInterested) return;
    _amInterested = false;
    send(NotInterested());
  }

  sendHave(int index) {
    send(Have()..index = index);
  }

  sendRequest(BtBlock block) {
    _pendingBlocks++;
    send(Request(
      index: block.piece,
      begin: block.offset,
      length: block.length,
    ));
  }

  @override
  String toString() {
    return '${runtimeType}{${hex.encode(id).substring(0, 10)}}';
  }
}
