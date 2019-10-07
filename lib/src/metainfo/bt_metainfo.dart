import 'package:torrent/src/hash.dart';
import 'package:torrent/src/metainfo/bt_file.dart';
import 'package:meta/meta.dart';

class BtMetaInfo {
  BtMetaInfo({
    @required this.name,
    this.lengthInBytes,
    @required this.pieceLengthInBytes,
    this.files,
    @required this.pieces,
  }) : assert(lengthInBytes != null || files != null,
            '[lengthInBytes] and [files] can not be null at same time.');

  String name;
  int lengthInBytes;
  int pieceLengthInBytes;
  List<BtFile> files;
  List<List<int>> pieces;

  bool get isMultiFile => files != null;
}
