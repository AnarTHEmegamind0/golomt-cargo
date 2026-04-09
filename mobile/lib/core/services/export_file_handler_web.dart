// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:typed_data';
import 'dart:html' as html;

import 'package:core/core/networking/downloaded_file.dart';
import 'package:core/core/services/export_models.dart';

Future<ExportResult> saveDownloadedFile(DownloadedFile file) async {
  final blob = html.Blob([Uint8List.fromList(file.bytes)], file.contentType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = file.filename
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  return ExportResult(
    filename: file.filename,
    message: '${file.filename} downloaded.',
  );
}
