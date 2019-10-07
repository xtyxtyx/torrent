import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

class BtLog {
  static final _logger = Logger('DartTorrent')..onRecord.listen(terminalOutput);

  static final _green = AnsiPen()..green();
  static final _cyan = AnsiPen()..cyan();

  static void terminalOutput(LogRecord rec) {
    print(
      '[${_green(rec.level.name)}]: '
      '${_cyan(rec.time.toString())}: '
      '${rec.message}',
    );
  }

  static setLevel(Level level) {
    hierarchicalLoggingEnabled = true;
    _logger.level = level;
  }

  static finest(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.FINEST, message, error, stackTrace);

  static finer(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.FINER, message, error, stackTrace);

  static fine(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.FINE, message, error, stackTrace);

  static warning(message, [Object error, StackTrace stackTrace]) =>
      _logger.log(Level.WARNING, message, error, stackTrace);
}
