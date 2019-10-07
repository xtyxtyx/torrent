import 'package:torrent/src/bencode/bencode.dart';
import 'package:torrent/src/metainfo/bt_info.dart';

class BtEncoder {
  BtEncoder(this._info);

  final BtInfo _info;

  Map<String, dynamic> toJSON() {
    List<Map<String, dynamic>> files;
    if (_info.metaInfo.files != null) {
      files = _info.metaInfo.files.map<Map<String, dynamic>>(
        (file) => {
          'length': file.length,
          'path': file.path,
        },
      ).toList();
    }

    final metainfo = {
      'name': _info.metaInfo.name,
      'length': _info.metaInfo.lengthInBytes,
      'piece length': _info.metaInfo.pieceLengthInBytes,
      'files': files,
      'pieces': _info.metaInfo.pieces
    };
    
    metainfo.removeWhere((k, v) => v == null);

    final info = {
      'encoding': _info.encoding,
      'announce': _info.announce,
      'created by': _info.createdBy,
      'creation date': _info.creationDate,
      'announce-list': _info.announceList,
      'info': metainfo,
    };

    info.removeWhere((k, v) => v == null);

    return info;
  }

  List<int> encode() {
    return bEncoder.convert(this.toJSON());
  }
}
