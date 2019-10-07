import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:easy_udp/easy_udp.dart';
import 'package:meta/meta.dart';
import 'package:torrent/src/announce/bt_announce.dart';
import 'package:torrent/src/announce/bt_announce_event.dart';
import 'package:torrent/src/announce/bt_announce_result.dart';
import 'package:torrent/src/peer/address.dart';
import 'package:torrent/src/peer/bt_pex.dart';
import 'package:torrent/src/tracker/bt_tracker_response.dart';
import 'package:torrent/src/tracker/bt_tracker_wire.dart';

import '../utils.dart';

class UdpConnectRequest {
  static const magic = 0x41727101980;
  static const action = 0;

  final int transactionId;

  UdpConnectRequest(this.transactionId);

  List<int> asMsg() {
    final msg = ByteData(16);
    msg.setInt64(0, magic, Endian.big);
    msg.setInt32(8, action, Endian.big);
    msg.setUint32(12, transactionId, Endian.big);
    return msg.buffer.asUint8List();
  }
}

class UdpConnectResponse {
  static const action = 0;
  int transactionId;
  int connectionId;

  UdpConnectResponse.parse(List<int> data) {
    final buffer = Uint8List.fromList(data).buffer.asByteData();
    assert(buffer.getInt32(0, Endian.big) == action);
    transactionId = buffer.getUint32(4);
    connectionId = buffer.getInt64(8);
  }

  @override
  String toString() {
    return '{action=0 transactionId=$transactionId connectionId=$connectionId}';
  }
}

class UdpAnnounceRequest {
  static const action = 1;

  final int transactionId;
  final int connectionId;
  final int ipAddress;
  final int port;
  final int key;
  final int numWant;
  final BtAnnounce announce;

  UdpAnnounceRequest({
    @required this.transactionId,
    @required this.connectionId,
    this.ipAddress = 0,
    this.port = 0,
    this.key = 0,
    this.numWant = -1,
    @required this.announce,
  });

  List<int> asBytes() {
    final msg = ByteData(98);
    msg.setInt64(0, connectionId, Endian.big);
    msg.setInt32(8, action, Endian.big);
    msg.setUint32(12, transactionId, Endian.big);
    msg.buffer.asUint8List().setAll(16, announce.infoHash);
    msg.buffer.asUint8List().setAll(36, announce.peerId);
    msg.setInt64(56, announce.downloaded, Endian.big);
    msg.setInt64(64, announce.left, Endian.big);
    msg.setInt64(72, announce.uploaded, Endian.big);
    msg.setInt32(80, announce.event.code, Endian.big);
    msg.setUint32(84, ipAddress, Endian.big);
    msg.setUint32(88, key, Endian.big);
    msg.setInt32(92, numWant, Endian.big);
    msg.setUint16(96, port, Endian.big);
    return msg.buffer.asUint8List();
  }
}

class UdpAnnounceResponse {
  static const action = 1;
  int transactionId;
  Duration interval;
  int leechers;
  int seeders;
  List<PeerAddress> peers = [];

  UdpAnnounceResponse.parse(List<int> data) {
    final buffer = Uint8List.fromList(data).buffer.asByteData();
    assert(buffer.lengthInBytes >= 20);
    assert(buffer.getInt32(0, Endian.big) == action);
    transactionId = buffer.getUint32(4);
    interval = Duration(seconds: buffer.getUint32(8));
    leechers = buffer.getUint32(12);
    seeders = buffer.getUint32(16);
    final peerCount = (buffer.lengthInBytes - 20) / 6;
    for (var i = 0; i < peerCount; i++) {
      final ip = buffer.getUint32(20 + 6 * i);
      final port = buffer.getUint16(24 + 6 * i);
      peers.add(PeerAddress(parseIPv4(ip), port));
    }
  }

  String toString() {
    final lines = <String>[];
    lines.add('{');
    lines.add('  action=1 transactionId=$transactionId interval=$interval');
    lines.add('  leechers=$leechers seeders=$seeders');
    lines.add('  peers:');
    for (var peer in peers) {
      lines.add('    $peer');
    }
    lines.add('}');
    return lines.join('\n');
  }
}

class ConnectionId {
  static const expireTime = Duration(minutes: 1);

  final int id;
  final DateTime received;

  ConnectionId(this.id, {DateTime received})
      : received = received ?? DateTime.now();

  bool get isValid =>
      DateTime.now().difference(received).compareTo(expireTime).isNegative;
}

class UdpClient {
  final Uri url;
  final int timeout;

  EasyUDPSocket _socket;
  ConnectionId _connectionId;

  UdpClient(this.url, {this.timeout = 1000 * 30}) : assert(url.scheme == 'udp');

  Future<UdpAnnounceResponse> announce(BtAnnounce a) async {
    if (_socket == null) {
      _socket = await EasyUDPSocket.bindRandom(InternetAddress.anyIPv4);
    }
    await _connect();
    final transactionId = _randTransactionId();
    await _send(UdpAnnounceRequest(
      announce: a,
      connectionId: _connectionId.id,
      transactionId: transactionId,
      port: a.port,
    ).asBytes());
    final resp = UdpAnnounceResponse.parse(await _receive());
    assert(resp.transactionId == transactionId);
    return resp;
  }

  _connect() async {
    final transactionId = _randTransactionId();
    await _send(UdpConnectRequest(transactionId).asMsg());
    final resp = UdpConnectResponse.parse(await _receive());
    assert(resp.transactionId == transactionId);
    _connectionId = ConnectionId(resp.connectionId);
  }

  static int _randTransactionId() {
    return Random.secure().nextInt(1 << 32);
  }

  Future<int> _send(List<int> data) async {
    assert(_socket != null);
    final addr = await InternetAddress.lookup(url.host);
    if (addr.first.type == InternetAddressType.IPv6) return 0;
    return await _socket.send(data, url.host, url.port);
  }

  Future<List<int>> _receive() async {
    assert(_socket != null);
    final resp = await _socket.receive(timeout: timeout, explode: true);
    return resp.data;
  }
}

class BtTrackerWireUdp implements BtTrackerWire {
  BtTrackerWireUdp(this._url);

  final String _url;

  Future<BtTrackerResponse> announce(BtAnnounce ann) async {
    ann.event ??= BtAnnounceEvent.none;
    final client = UdpClient(Uri.parse(_url));
    final resp = await client.announce(ann);
    final result = BtAnnounceResult(
        seeders: resp.seeders,
        leechers: resp.leechers,
        interval: resp.interval.inSeconds,
        pex: resp.peers
            .map((addr) =>
                BtPex(addr: InternetAddress(addr.host), port: addr.port))
            .toList());
    return BtTrackerResponse.data(result);
  }
}
