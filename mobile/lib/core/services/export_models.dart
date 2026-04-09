class ExportResult {
  const ExportResult({
    required this.filename,
    required this.message,
    this.filePath,
  });

  final String filename;
  final String message;
  final String? filePath;
}
