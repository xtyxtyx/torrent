import 'package:torrent/src/krpc/msg/base.dart';

class KrpcPing extends KrpcQuery {
  KrpcPing({this.id});

  final command = 'ping';
  final List<int> id;

  @override
  Map<String, dynamic> get body => {
    'id': id,
  };
}