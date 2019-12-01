import 'package:torrent/src/bencode/bencoder.dart';

class KrpcMessage {
  List<int> transactionId;

  void withTransactionId(List<int> id) => transactionId = id;
}

class KrpcResponse {
  
}

abstract class KrpcQuery with KrpcMessage {
  String command;
  Map<String, dynamic> body;

  List<int> toBenc() {
    return bEncoder.convert({
      't': transactionId,
      'y': 'q',
      'q': command,
      'a': body,
    });
  }
}

class KrpcError {
  
}