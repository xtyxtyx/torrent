import 'dart:convert';
import 'dart:io';

import 'package:torrent/src/metainfo/bt_encoder.dart';
import 'package:torrent/src/metainfo/bt_info.dart';
import 'package:torrent/src/metainfo/bt_parser.dart';
import 'package:convert/convert.dart';

Future<BtInfo> loadFile(String path) async {
  final data = await File(path).readAsBytes();
  return BtParser().parse(data);
}

String dumpInfo(
  BtInfo info, {
  bool printToTerminal = true,
  bool brief = false,
}) {
  final encoder = JsonEncoder.withIndent('  ');
  final json = BtEncoder(info).toJSON();
  if (json['info']['pieces'] != null) {
    json['info']['pieces'] = json['info']['pieces'].map(hex.encode).toList();
  }
  if (brief) {
    final len = json['info']['pieces'].length;
    if(len > 5) {
      json['info']['pieces'] = json['info']['pieces'].getRange(0, 5).toList();
      json['info']['pieces'].add('<${len-5} more...>');
    }
  }
  final output = encoder.convert(json);
  if (printToTerminal) {
    print(output);
  }
  return output;
}
