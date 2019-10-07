import 'dart:io';
import 'dart:math' show max, min;
import 'dart:typed_data';

import 'package:path/path.dart' show join;
import 'package:torrent/src/metainfo/bt_metainfo.dart';
import 'package:torrent/src/storage/bt_storage.dart';

class BtFdPool {}

class BtDiskBucket implements BtBucket {
  BtDiskBucket(this.dir);

  final String dir;

  @override
  BtStorage open(BtMetaInfo info) {
    List<_File> files;
    if (info.lengthInBytes != null) {
      files = [
        _File(info.name, info.lengthInBytes),
      ];
    } else {
      files = info.files.map((f) {
        return _File(info.name + '/' + f.path.join('/'), f.length);
      }).toList();
    }
    return BtDiskStorage(
      dir: dir,
      files: files,
    );
  }
}

class _File {
  _File(this.path, this.size);

  String path;
  int size;
}

class BtDiskStorage implements BtStorage {
  BtDiskStorage({this.dir, this.files});

  final String dir;
  final List<_File> files;

  @override
  Future<List<int>> read(int length, int offset) async {
    assert(length >= 0);
    assert(offset >= 0);

    final buffer = BytesBuilder();

    var start = 0;
    var end = 0;
    for (var file in files) {
      end += file.size;
      start = end - file.size;

      if (end <= offset) continue;

      final diskfile = File(join(dir, file.path));
      final readStart = max(start, offset) - start;
      final readEnd = min(end, offset + length) - start;
      if (await diskfile.exists()) {
        await for (var data in diskfile.openRead(readStart, readEnd)) {
          buffer.add(data);
        }
      } else {
        buffer.add(Uint8List(readEnd - readStart));
      }

      if (buffer.length == length) break;
    }

    assert(buffer.length == length);
    return buffer.takeBytes();
  }

  @override
  void write(List<int> buffer, int offset) async {
    assert(buffer != null);
    assert(offset >= 0);

    var start = 0;
    var end = 0;
    var written = 0;
    for (var file in files) {
      end += file.size;
      start = end - file.size;

      if (end <= offset) continue;

      final diskfile = File(join(dir, file.path));
      final writeStart = max(start, offset) - start;
      final writeEnd = min(end, offset + buffer.length) - start;
      final writeLength = writeEnd - writeStart;

      final opened = await diskfile.open(mode: FileMode.writeOnlyAppend);
      await opened.setPosition(writeStart);
      await opened.writeFrom(buffer, written, written + writeLength);
      await opened.close();
      written += writeLength;

      if (written == buffer.length) break;
    }

    assert(written == buffer.length);
  }
}
