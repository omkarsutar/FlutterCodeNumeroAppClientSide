import 'dart:typed_data';

abstract class PdfDownloadHelper {
  Future<void> savePdf(Uint8List bytes, String fileName);
}
