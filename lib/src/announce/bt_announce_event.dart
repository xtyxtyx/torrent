class BtAnnounceEvent {
  const BtAnnounceEvent._(this.name, this.code);

  final String name;
  final int code;

  static const none = BtAnnounceEvent._(null, 0);
  static const completed = BtAnnounceEvent._('completed', 1);
  static const started = BtAnnounceEvent._('started', 2);
  static const stopped = BtAnnounceEvent._('stopped', 3);
}