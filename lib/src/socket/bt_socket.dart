import 'dart:async';

import 'dart:io';

import 'dart:typed_data';

import 'package:torrent/src/bt_logger.dart';

class BtSocket {
  BtSocket(this._socket) {
    _socket.done.then(
      _onDoneCompleter.complete,
      onError: _onDoneCompleter.complete,
    );
    _dataStreamController.addStream(_socket.handleError(BtLog.finer));
  }

  final Socket _socket;
  final _dataStreamController = StreamController<Uint8List>.broadcast();
  final _onDoneCompleter = Completer();

  void add(List<int> data) => _socket.add(data);

  void flush() => _socket.flush();

  Stream<Uint8List> get onData => _dataStreamController.stream;

  Future close() => _socket.close();
}
