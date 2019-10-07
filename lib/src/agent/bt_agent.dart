import 'package:torrent/src/metainfo/bt_info.dart';
import 'package:torrent/src/torrent/bt_torrent.dart';
import 'package:torrent/src/utils.dart';

class BtAgentCore {
  BtAgentCore() {
    setId();
  }

  List<int> id;

  List<int> setId([List<int> id]) {
    if (id != null) {
      assert(id.length == 20, 'id.length must be 20');
    }
    this.id = id ?? randomBytes(20);
    return this.id;
  }

  BtTorrent addTorrent(BtInfo info) {
    return BtTorrent(
      agent: this,
      info: info,
    );
  }
}
