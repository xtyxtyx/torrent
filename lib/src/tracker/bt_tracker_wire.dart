import 'package:torrent/src/announce/bt_announce.dart';
import 'package:torrent/src/tracker/bt_tracker_response.dart';

abstract class BtTrackerWire {
  Future<BtTrackerResponse> announce(BtAnnounce ann);
}