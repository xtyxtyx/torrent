import 'package:meta/meta.dart';

class BtFile {
  BtFile({
    @required this.length,
    @required this.path,
  });

  final int length;
  final List<String> path;
}