class KContact {
  List<int> id;
  List<int> ip;
  int port;
}

class KNode {
  KNode.leaf() : contacts = [];

  List<KContact> contacts;
  bool dontSplit = false;
  KNode left;
  KNode right;

  bool get isLeaf => contacts != null;

  KNode decideNode(KContact contact, int bitIndex) {
    final byteIndex = bitIndex >> 3;
    final bitIndexWithinByte = bitIndex % 8;

    final testByte = 1 << (7 - bitIndexWithinByte);

    if (contact.id[byteIndex] & testByte != 0) {
       return right;
    }

    return left;
  }

  KContact findContact(List<int> id) {
    // return contacts.firstWhere((c) => c.id.)
  }
}

/// The routing table for nodes
class KBucket {
  final k = 20;
  final root = KNode.leaf();

  add(KContact contact) {
    var bitIndex = 0;
    var node = root;

    while (!node.isLeaf) {
      node = node.decideNode(contact, bitIndex);
      bitIndex++;
    }


  }
}
