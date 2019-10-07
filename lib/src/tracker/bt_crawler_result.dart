import 'package:torrent/src/peer/bt_pex.dart';

class BtCrawlerResult {
  BtCrawlerResult({
    this.pex,
    this.nextAnnounce
  });
  
  List<BtPex> pex;
  Duration nextAnnounce;
}