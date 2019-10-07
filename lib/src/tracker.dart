// class Tracker {
//   final Uri _uri;

//   String get scheme => _uri.scheme;
//   String get path => _uri.path;
//   String get host => _uri.host;
//   int get port => _uri.port;

//   Tracker(this._uri);
//   Tracker.fromUrl(String url) : _uri = Uri.parse(url);
// }

import 'package:torrent/src/peer/address.dart';

import 'hash.dart';

class AnnounceEvent {
  final int code;
  final String name;

  const AnnounceEvent({this.code, this.name});

  static const none = AnnounceEvent(code: 0, name: 'empty');
  static const completed = AnnounceEvent(code: 1, name: 'completed');
  static const started = AnnounceEvent(code: 2, name: 'started');
  static const stopped = AnnounceEvent(code: 3, name: 'stopped');
}

class Announce {
  Hash infoHash;
  Hash peerId;
  int downloaded;
  int left;
  int uploaded;
  AnnounceEvent event = AnnounceEvent.none;
  int numWant = -1;
  int port = 10521;
}

abstract class AnnounceRequest {
  Future<AnnounceResult> send();
}

class AnnounceResult {
  int interval;
  int leechers;
  int seeders;
  List<PeerAddress> peers;
}
