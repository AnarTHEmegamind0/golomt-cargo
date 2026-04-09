import 'dart:io';

import 'package:core/core/networking/downloaded_file.dart';
import 'package:core/core/services/export_models.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<ExportResult> saveDownloadedFile(DownloadedFile file) async {
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/${file.filename}';
  final output = File(filePath);
  await output.writeAsBytes(file.bytes, flush: true);

  final openResult = await OpenFilex.open(filePath, type: file.contentType);
  if (openResult.type != ResultType.done) {
    await Share.shareXFiles([XFile(filePath)], text: file.filename);
  }

  return ExportResult(
    filename: file.filename,
    filePath: filePath,
    message: 'Saved to $filePath',
  );
}
