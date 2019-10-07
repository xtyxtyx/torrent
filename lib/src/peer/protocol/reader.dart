import 'package:logging/logging.dart';
import 'package:torrent/src/util/byte_view.dart';

import 'message.dart';

class MessageReader {
  final buffer = <int>[];

  void add(List<int> data) {
    buffer.addAll(data);
  }

  Message tryConsume() {
    if (buffer.length < 4) {
      return null;
    }

    final length = ByteView(buffer).bytedata.getUint32(0);
    if (buffer.length < length + 4) {
      return null;
    }

    final result = Message.decode(ByteView(buffer).view(
      length: length + 4,
    ));
    buffer.removeRange(0, length + 4);
    return result;
  }
}