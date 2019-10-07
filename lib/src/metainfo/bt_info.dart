import 'package:torrent/src/hash.dart';
import 'package:torrent/src/metainfo/bt_metainfo.dart';
import 'package:meta/meta.dart';

int secondsSinceEpoch() {
  final seconds = DateTime.now().millisecondsSinceEpoch / 1000;
  return seconds.round();
}

class BtInfo {
  BtInfo({
    this.encoding = 'UTF-8',
    this.announce,
    this.createdBy = 'DartTorrent',
    int creationDate,
    this.announceList,
    @required this.metaInfo,
    this.infoHash,
  })  : creationDate = creationDate ?? secondsSinceEpoch(),
        assert(announce != null || announceList != null,
            '[announce] and [announceList] can not be null at same time.');

  final String encoding;
  final String announce;
  final String createdBy;
  final int creationDate;
  final List<List<String>> announceList;
  final BtMetaInfo metaInfo;
  final List<int> infoHash;
}
