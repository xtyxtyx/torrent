**[WIP, This library is currently under heavy development and isn't ready for production]**

## Usage

Example:

```dart
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

```

## BEPs

### Implemented

- [BEP-3](http://bittorrent.org/beps/bep_0003.html)
- [BEP-12](http://bittorrent.org/beps/bep_0012.html)
- [BEP-15](http://bittorrent.org/beps/bep_0015.html)
- [BEP-23](http://bittorrent.org/beps/bep_0023.html)

### Partially implemented

- [BEP-5](http://bittorrent.org/beps/bep_0005.html)
- [BEP-6](http://bittorrent.org/beps/bep_0006.html)

### Planned

- [BEP-9](http://bittorrent.org/beps/bep_0009.html)
- [BEP-10](http://bittorrent.org/beps/bep_0010.html)
- [BEP-11](http://bittorrent.org/beps/bep_0011.html)
- [BEP-14](http://bittorrent.org/beps/bep_0014.html)
- [BEP-19](http://bittorrent.org/beps/bep_0019.html)
- [BEP-29](http://bittorrent.org/beps/bep_0029.html)
- [Encryption](http://wiki.vuze.com/w/Message_Stream_Encryption)


## Roadmap to v0.1

- <input type="checkbox" /> UPnP
- <input type="checkbox" /> NAT-PMP

## Experimental tracker server

*TBD*

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/xtyxtyx/torrent/issues

## Lisence

The MIT License (MIT)

Copyright (c) 2019 xuty