import 'package:torrent/src/announce/bt_announce_result.dart';

class BtTrackerResponse {
  BtTrackerResponse.data(this.result) : hasError = false;
  BtTrackerResponse.error(this.errorMsg) : hasError = true;
  BtTrackerResponse.timeout() : timeouted = true;

  bool connected;
  bool timeouted;
  bool hasError;
  String errorMsg;

  List<int> infoHash;

  BtAnnounceResult result;
}
