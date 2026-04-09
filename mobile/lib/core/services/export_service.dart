import 'package:core/core/services/export_file_handler.dart';
import 'package:core/core/services/export_models.dart';
import 'package:core/features/admin/services/admin_service.dart';

class ExportService {
  ExportService({required AdminService adminService})
    : _adminService = adminService;

  final AdminService _adminService;

  Future<ExportResult> exportShipmentPdf(String shipmentId) async {
    final file = await _adminService.exportShipmentPdf(shipmentId);
    return handleDownloadedFile(file);
  }

  Future<ExportResult> exportShipmentXlsx(String shipmentId) async {
    final file = await _adminService.exportShipmentXlsx(shipmentId);
    return handleDownloadedFile(file);
  }

  Future<ExportResult> exportAdminLogsXlsx() async {
    final file = await _adminService.exportAdminLogsXlsx();
    return handleDownloadedFile(file);
  }
}
