import 'dart:typed_data';

class ByteView {
  ByteView(List<int> data)
      : _uint8list = data is Uint8List ? data : Uint8List.fromList(data);

  final Uint8List _uint8list;

  Uint8List view({int offset = 0, int length}) {
    return Uint8List.view(_uint8list.buffer, offset, length);
  }

  ByteData get bytedata => _uint8list.buffer.asByteData();

  Iterable<List<int>> split(int length, {bool view = true}) sync* {
    final count = _uint8list.length / length;
    for (var i = 0; i < count.ceil(); i++) {
      final offset = i * length;
      final actualLength = offset + length <= _uint8list.length
          ? length
          : _uint8list.length - offset;
      if (view) {
        yield Uint8List.view(_uint8list.buffer, offset, actualLength);
      } else {
        yield _uint8list.sublist(offset, offset + actualLength);
      }
    }
  }
}
