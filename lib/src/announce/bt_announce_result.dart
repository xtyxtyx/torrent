import 'package:torrent/src/peer/bt_pex.dart';

class BtAnnounceResult {
  BtAnnounceResult({
    this.seeders,
    this.leechers,
    this.interval,
    this.pex
  });
  
  int seeders;
  int leechers;
  int interval;

  List<BtPex> pex;
}