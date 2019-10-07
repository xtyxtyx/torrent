const version = '0.0.1';

final clientIdPrefix = 'Dart\0'.runes.toList();

const clientName = 'DartTorrent($version)';

const httpUserAgent = clientName;

const builtinAnnouce = 'https://opentracker.xyz:443/announce';

const defaultPieceLength = 1 << 17;

const defaultBlockLength = 1 << 14;

const defaultAnnounceInterval = 60 * 5;

const builtinAnnounceList = <List<String>>[
  ['udp://tracker.opentrackr.org:1337/announce'],
  ['udp://tracker.torrent.eu.org:451/announce'],
  ['udp://tracker.ds.is:6969/announce'],
  ['udp://tracker.0o.is:6969/announce'],
  ['https://opentracker.xyz:443/announce'],
  ['udp://tracker.birkenwald.de:6969/announce'],
  ['udp://tracker.supertracker.net:1337/announce'],
  ['http://tracker.files.fm:6969/announce'],
  ['http://tracker.yoshi210.com:6969/announce'],
  ['udp://tracker01.loveapp.com:6789/announce'],
  ['udp://tracker.lelux.fi:6969/announce'],
  ['udp://tracker.nibba.trade:1337/announce'],
  ['https://tracker6.lelux.fi:443/announce'],
  ['udp://explodie.org:6969/announce'],
  ['udp://bt.xxx-tracker.com:2710/announce'],
  ['udp://zephir.monocul.us:6969/announce'],
  ['http://torrent.nwps.ws:80/announce'],
  ['udp://exodus.desync.com:6969/announce'],
  ['udp://amigacity.xyz:6969/announce'],
  ['udp://retracker.netbynet.ru:2710/announce'],
  ['https://tracker.vectahosting.eu:2053/announce'],
  ['http://tracker.bt4g.com:2095/announce'],
  ['https://tracker.nanoha.org:443/announce'],
  ['https://tracker.publictorrent.net:443/announce'],
  ['udp://retracker.hotplug.ru:2710/announce'],
  ['udp://retracker.akado-ural.ru:80/announce'],
  ['http://open.trackerlist.xyz:80/announce'],
  ['udp://retracker.baikal-telecom.net:2710/announce'],
  ['udp://retracker.lanta-net.ru:2710/announce'],
  ['udp://opentor.org:2710/announce'],
  ['udp://bt.dy20188.com:80/announce'],
  ['udp://tracker.filemail.com:6969/announce'],
  ['udp://tracker.nyaa.uk:6969/announce'],
  ['udp://tracker.coppersurfer.tk:6969/announce'],
  ['udp://tracker.moeking.me:6969/announce'],
  ['udp://9.rarbg.com:2710/announce'],
  ['http://t.nyaatracker.com:80/announce'],
  ['udp://ipv6.tracker.harry.lu:80/announce'],
  ['http://retracker.goodline.info:80/announce'],
  ['https://t.quic.ws:443/announce'],
  ['http://tracker3.itzmx.com:6961/announce'],
  ['https://opentracker.co:443/announce'],
  ['udp://ipv4.tracker.harry.lu:80/announce'],
  ['https://tracker.fastdownload.xyz:443/announce'],
  ['udp://tracker.fixr.pro:6969/announce'],
  ['udp://opentracker.sktorrent.org:6969/announce'],
  ['http://tracker.gbitt.info:80/announce'],
  ['udp://tracker.leechers-paradise.org:6969/announce'],
  ['udp://tracker.beeimg.com:6969/announce'],
  ['http://retracker.sevstar.net:2710/announce'],
  ['udp://tracker.uw0.xyz:6969/announce'],
  ['udp://tracker-udp.gbitt.info:80/announce'],
  ['udp://tracker.cyberia.is:6969/announce'],
  ['udp://tracker.openbittorrent.com:80/announce'],
  ['udp://tracker.open-internet.nl:6969/announce'],
  ['udp://tracker.internetwarriors.net:1337/announce'],
  ['udp://9.rarbg.to:2710/announce'],
  ['udp://9.rarbg.me:2710/announce'],
  ['http://tracker1.itzmx.com:8080/announce'],
  ['udp://tracker.tiny-vps.com:6969/announce'],
  ['udp://tracker2.itzmx.com:6961/announce'],
  ['http://tracker4.itzmx.com:2710/announce'],
  ['http://open.acgnxtracker.com:80/announce'],
];
