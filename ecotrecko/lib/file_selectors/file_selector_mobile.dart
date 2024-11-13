import 'dart:typed_data';
import 'file_selector.dart';
import 'package:file_picker/file_picker.dart';

class FileSelectorMobile extends FileSelector {
  @override
  Future<Uint8List?> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.bytes != null) {
      return result.files.single.bytes;
    }

    return null;
  }
}
