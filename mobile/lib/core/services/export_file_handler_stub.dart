import 'package:core/core/networking/downloaded_file.dart';
import 'package:core/core/services/export_models.dart';

Future<ExportResult> saveDownloadedFile(DownloadedFile file) async {
  return ExportResult(
    filename: file.filename,
    message: 'Export is not supported on this platform.',
  );
}
