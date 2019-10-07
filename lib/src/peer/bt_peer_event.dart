import 'dart:async';

class BtPeerEvent {
  final _bitfieldStreamController = StreamController.broadcast();

  onBitfield() => _bitfieldStreamController.stream;
}