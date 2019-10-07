import 'dart:io';

import 'dart:typed_data';

class IPv4 {
  String _ipv4;

  IPv4.fromInt(int ip) {
    final buffer = ByteData(32);
    buffer.setUint32(0, ip);
    final part1 = buffer.getUint8(0);
    final part2 = buffer.getUint8(1);
    final part3 = buffer.getUint8(2);
    final part4 = buffer.getUint8(3);
    _ipv4 = '$part1.$part2.$part3.$part4';
  }

  asAddress() {
    return InternetAddress(_ipv4);
  }

  @override
  String toString() => _ipv4;
}