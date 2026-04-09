import 'package:core/core/networking/downloaded_file.dart';
import 'package:core/core/services/export_models.dart';
import 'package:core/core/services/export_file_handler_stub.dart'
    if (dart.library.html) 'package:core/core/services/export_file_handler_web.dart'
    if (dart.library.io) 'package:core/core/services/export_file_handler_io.dart';

Future<ExportResult> handleDownloadedFile(DownloadedFile file) {
  return saveDownloadedFile(file);
}
