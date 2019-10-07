import 'package:torrent/src/metainfo/bt_metainfo.dart';

abstract class BtBucket {
  BtStorage open(BtMetaInfo info);
}

abstract class BtStorage {
  Future<List<int>> read(int length, int offset);

  void write(List<int> buffer, int offset);
}