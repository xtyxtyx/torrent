// import 'dart:io';
// import 'dart:typed_data';

// import 'package:crypto/crypto.dart';

// import 'constants.dart';
// import 'spec.dart';
// import 'info.dart';
// import 'utils.dart';

// Future<TorrentSpec> create(String path) async {
//   if (await File(path).exists()) {
//     return createSingle(File(path));
//   }
//   if (await Directory(path).exists()) {
//     return createMulti(Directory(path));
//   }
//   throw "`$path` isn't a file or a directory";
// }

// Future<TorrentSpec> createSingle(File source) async {
//   assert(await source.exists());
//   const pieceLength = 131072; // 2 ^ 17
//   final file = await source.open();
//   final fileLength = await file.length();
//   final pieceCount = (fileLength / pieceLength).ceil();
//   final hashes = <List<int>>[];
//   for (var i = 0; i < pieceCount; i++) {
//     await file.setPosition(i * pieceLength);
//     final data = await file.read(pieceLength);
//     hashes.add(sha1.convert(data).bytes);
//   }
//   final filename = source.path.split(Platform.pathSeparator).last;
//   final info = TorrentInfo(
//     name: filename,
//     pieceLength: pieceLength,
//     pieces: Pieces(combineList(hashes)),
//     length: fileLength,
//   );
//   return TorrentSpec(
//     announce: builtinAnnouce,
//     announceList: builtinAnnounceList,
//     info: info,
//   );
// }

// Future<TorrentSpec> createMulti(Directory source) async {
//   const pieceLength = 131072; // 2 ^ 17
//   final hashes = <List<int>>[];
//   final fileInfoList = <FileInfo>[];
//   final files = await scanDirectoryFor<File>(source);
//   files.sort((a, b) => a.path.compareTo(b.path));
//   var data = Uint8List(pieceLength);
//   var current = 0;
//   for (var file in files) {
//     final fileLen = await file.length();
//     fileInfoList.add(FileInfo(
//       path:
//           file.path.replaceFirst(source.path, '').split(Platform.pathSeparator),
//       length: fileLen,
//     ));
//     final openedFile = await file.open();
//     var fileStart = 0;
//     while (true) {
//       if (fileLen - fileStart < pieceLength - current) {
//         await openedFile.setPosition(fileStart);
//         await openedFile.readInto(data, current);
//         current += fileLen - fileStart;
//         break;
//       }
//       await openedFile.setPosition(fileStart);
//       await openedFile.readInto(data, current, pieceLength);
//       fileStart += pieceLength - current;
//       hashes.add(sha1.convert(data).bytes);
//       data = Uint8List(pieceLength);
//       current = 0;
//     }
//   }
//   if (current != 0) {
//     hashes.add(sha1.convert(Uint8List.view(data.buffer, 0, current)).bytes);
//   }
//   final name = source.path.split(Platform.pathSeparator).last;
//   final info = TorrentInfo(
//     name: name,
//     pieceLength: pieceLength,
//     pieces: Pieces(combineList(hashes)),
//     files: fileInfoList,
//   );
//   return TorrentSpec(
//     announce: builtinAnnouce,
//     announceList: builtinAnnounceList,
//     info: info,
//   );
// }
