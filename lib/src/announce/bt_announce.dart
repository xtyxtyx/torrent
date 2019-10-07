import 'package:torrent/src/announce/bt_announce_event.dart';

class BtAnnounce {
  BtAnnounce({
    this.infoHash,
    this.peerId,
    this.downloaded,
    this.left,
    this.uploaded,
    this.event,
    this.numWant,
    this.port,
  });

  List<int> infoHash;
  List<int> peerId;
  int downloaded;
  int left;
  int uploaded;
  BtAnnounceEvent event = BtAnnounceEvent.none;
  int numWant = -1;
  int port = 10521;

  BtAnnounce setEvent(BtAnnounceEvent event) {
    this.event = event;
    return this;
  }
}