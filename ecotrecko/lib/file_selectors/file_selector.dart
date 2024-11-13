import 'dart:typed_data';

abstract class FileSelector {
  Future<Uint8List?> selectFile();
}
