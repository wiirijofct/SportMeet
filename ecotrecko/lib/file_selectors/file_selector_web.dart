import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'file_selector.dart';

class FileSelectorWeb implements FileSelector {
  @override
  Future<Uint8List?> selectFile() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    final completer = Completer<Uint8List?>();
    uploadInput.onChange.listen((e) async {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        await reader.onLoad.first;
        final dataUrl = reader.result as String;
        final bytes = base64.decode(dataUrl.split(',').last);
        completer.complete(Uint8List.fromList(bytes));
      } else {
        completer.complete(null);
      }
    });
    return completer.future;
  }
}
