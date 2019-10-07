import 'dart:convert';

import 'package:torrent/src/bencode/bencode.dart';
import 'package:torrent/src/hash.dart';
import 'package:torrent/src/metainfo/bt_file.dart';
import 'package:torrent/src/metainfo/bt_info.dart';
import 'package:torrent/src/metainfo/bt_metainfo.dart';
import 'package:crypto/crypto.dart' show sha1;
import 'package:torrent/src/metainfo/bt_pieces.dart';

String stringOrNull(List<int> data) {
  return data == null ? null : utf8.decode(data);
}

T nullOr<T>(dynamic data) {
  return data is T ? data : null;
}

class BtParser {
  BtParser();

  BtInfo parse(List<int> data) {
    final parsed = bDecoder.convert(data);

    final encoding = stringOrNull(parsed['encoding']);
    final announce = stringOrNull(parsed['announce']);
    final creationDate = nullOr<int>(parsed['creation date']);
    final createdBy = stringOrNull(parsed['created by']);

    final infoHash = sha1
        .convert(
          bEncoder.convert(parsed['info']),
        )
        .bytes;

    List<List<String>> announceList;
    if (parsed['announce-list'] != null) {
      announceList = [];
      for (var tier in parsed['announce-list'] as List) {
        final announceTier = <String>[];
        for (var announce in tier) {
          announceTier.add(utf8.decode(announce));
        }
        announceList.add(announceTier);
      }
    }

    List<BtFile> files;
    if (parsed['info']['files'] != null) {
      files = [];
      for (var file in parsed['info']['files'] as List) {
        final path = List<List<int>>.from(file['path']).map<String>(utf8.decode);
        files.add(
          BtFile(length: file['length'], path: path.toList()),
        );
      }
    }

    final pieces = <Hash>[];
    for (var piece in BtPieces(parsed['info']['pieces']).groups()) {
      pieces.add(Hash.fromList(piece));
    }

    final metainfo = BtMetaInfo(
      name: stringOrNull(parsed['info']['name']),
      lengthInBytes: parsed['info']['length'],
      pieceLengthInBytes: parsed['info']['piece length'],
      files: files,
      pieces: pieces,
    );

    final info = BtInfo(
      encoding: encoding,
      announce: announce,
      createdBy: createdBy,
      creationDate: creationDate,
      announceList: announceList,
      metaInfo: metainfo,
      infoHash: infoHash,
    );

    return info;
  }
}
