import 'package:logging/logging.dart';
import 'package:torrent/torrent.dart';
import 'package:torrent/auxlib.dart';

main() async {
  BtLog.setLevel(Level.FINER);

  final info = await loadFile('test/data/hot.torrent');
  dumpInfo(info, brief: true);

  final agent = BtAgentCore();
  final torrent = agent.addTorrent(info);

  await torrent.verifyLocalData();
  print(torrent.percent() * 100);
  print(torrent.absentPieces());

  torrent.startAllTrackers();
  torrent.downloadAll();
}
