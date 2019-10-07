import 'dart:typed_data';

import 'package:torrent/src/hash.dart';

class PeerId extends HashBase {
  PeerId(Uint8List bytes) : super(bytes);
}