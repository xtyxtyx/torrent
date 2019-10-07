import 'dart:async';

import 'package:torrent/src/announce/bt_announce.dart';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:torrent/src/announce/bt_announce_result.dart';
import 'package:torrent/src/bencode/bdecoder.dart';
import 'package:torrent/src/peer/bt_pex.dart';
import 'package:torrent/src/tracker/bt_tracker_wire.dart';
import 'package:torrent/src/tracker/bt_tracker_response.dart';
import 'package:torrent/src/utils.dart';

const successfulStatusCode = 200;
const requestTimeout = Duration(seconds: 30);

String _buildHttpAnnounceQuery(BtAnnounce ann) {
  return '?'
      'info_hash=${percent.encode(ann.infoHash)}'
      '&peer_id=${percent.encode(ann.peerId)}'
      '&port=${ann.port}'
      '&uploaded=${ann.uploaded}'
      '&downloaded=${ann.downloaded}'
      '&left=${ann.left}'
      '&compact=1';
}

class BtTrackerWireHttp implements BtTrackerWire {
  BtTrackerWireHttp(this._url);

  final String _url;

  Future<BtTrackerResponse> announce(BtAnnounce ann) async {
    http.Response response;
    try {
      final url = _url + _buildHttpAnnounceQuery(ann);
      response = await http.get(url).timeout(requestTimeout);
    } on TimeoutException catch (_) {
      return BtTrackerResponse.timeout();
    }

    if (response.statusCode != successfulStatusCode) {
      return BtTrackerResponse.error(response.reasonPhrase);
    }

    final data = bDecoder.convert(response.bodyBytes);
    final failure = data['failure reason'];
    if (failure != null) {
      return BtTrackerResponse.error(failure);
    }

    final pex = <BtPex>[];
    if (data['peers'] != null) {
      for (var compact in splitList(data['peers'], 6)) {
        pex.add(BtPex.fromCompact(compact));
      }
    }

    final result = BtAnnounceResult(
      interval: data['interval'],
      pex: pex,
    );

    return BtTrackerResponse.data(result);
  }
}
