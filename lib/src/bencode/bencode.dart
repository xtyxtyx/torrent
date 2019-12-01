library bencode;

import 'dart:convert';

import 'package:torrent/src/bencode/bdecoder.dart';
import 'package:torrent/src/bencode/bencoder.dart';

export 'bencoder.dart';
export 'bdecoder.dart';

class BencCodec extends Codec<Object, List<int>> {

  const BencCodec();

  dynamic decode(List<int> source) => bDecoder.convert(source);

  List<int> encode(Object value) => bEncoder.convert(value);

  BEncoder get encoder => bEncoder;

  BDecoder get decoder => bDecoder;
}

final benc = BencCodec();