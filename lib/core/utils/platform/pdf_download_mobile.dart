import 'dart:typed_data';

import 'package:printing/printing.dart';

import 'pdf_download_interface.dart';

class PdfDownloadHelperImpl implements PdfDownloadHelper {
  @override
  Future<void> savePdf(Uint8List bytes, String fileName) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }
}

PdfDownloadHelper getPdfDownloadHelper() => PdfDownloadHelperImpl();
