import 'dart:async';
import 'dart:io';

import 'package:torrent/src/bt_logger.dart';
import 'package:torrent/src/peer/bt_pex.dart';
import 'package:torrent/src/torrent/bt_torrent.dart';
import 'package:torrent/src/tracker/bt_tracker_response.dart';
import 'package:torrent/src/tracker/bt_tracker_wire.dart';
import 'package:torrent/src/tracker/bt_tracker_wire_http.dart';
import 'package:torrent/src/tracker/bt_tracker_wire_udp.dart';

const defaultAnnounceDuration = Duration(minutes: 5);

class BtTracker {
  BtTracker({
    this.url,
    this.torrent,
  }) : protocol = Uri.parse(url).scheme;

  final String url;
  final String protocol;
  BtTorrent torrent;
  Timer _timer;
  final _peerStream = StreamController<BtPex>.broadcast();

  Future<BtTrackerResponse> announce() {
    BtTrackerWire wire;

    if (['udp'].contains(protocol)) {
      wire = BtTrackerWireUdp(url);
    } else if (['http', 'https'].contains(protocol)) {
      wire = BtTrackerWireHttp(url);
    } else {
      throw 'unsupported protocol: ${protocol}';
    }

    BtLog.fine('Announce with: $url');
    return announceWithWire(wire);
  }

  Future<BtTrackerResponse> announceWithWire(BtTrackerWire wire) async {
    try {
      final resp = await wire.announce(torrent.genAnnounce());
      return resp;
    } on SocketException catch (e) {
      BtLog.fine('Announce error: $e');
      return null;
    } catch(e) {
      BtLog.fine('Announce error: $e');
      return null;
    }
  }

  _recursive() async {
    final resp = await announce();
    if (resp?.result?.pex != null) {
      resp.result.pex.forEach(_peerStream.add);
    }
    final next = resp?.result != null
        ? Duration(seconds: resp.result.interval)
        : defaultAnnounceDuration;
    _timer = Timer(next, _recursive);
  }

  start() {
    if (_timer != null) {
      return;
    }
    _recursive();
  }

  stop() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isActive => _timer != null && _timer.isActive;

  Stream<BtPex> get onPeer => _peerStream.stream;
}
