import 'dart:io';
import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/features/china_staff/providers/china_cargo_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

/// China staff cargo import page - import track codes via camera, file, text, or barcode
class ChinaCargoImportPage extends StatefulWidget {
  const ChinaCargoImportPage({super.key});

  @override
  State<ChinaCargoImportPage> createState() => _ChinaCargoImportPageState();
}

class _ChinaCargoImportPageState extends State<ChinaCargoImportPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _textController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _barcodeFocusNode = FocusNode();
  final _scannedCodes = <String>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChinaCargoProvider>().loadCargos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChinaCargoProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Бараа бүртгэл',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Show received count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BrandPalette.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: BrandPalette.successGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.receivedCargos.length}',
                      style: const TextStyle(
                        color: BrandPalette.successGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab bar for import methods
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: BrandPalette.softBlueBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: BrandPalette.primaryText,
            unselectedLabelColor: BrandPalette.mutedText,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.camera_alt, size: 18), SizedBox(width: 6), Text('Камер')])),
              Tab(text: 'Scanner'),
              Tab(text: 'Текст'),
              Tab(text: 'Файл'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _CameraScannerTab(
                scannedCodes: _scannedCodes,
                onScan: _onBarcodeScan,
                onImport: () => _importCodes(_scannedCodes),
                onClear: () => setState(() => _scannedCodes.clear()),
              ),
              _BarcodeTab(
                controller: _barcodeController,
                focusNode: _barcodeFocusNode,
                scannedCodes: _scannedCodes,
                onScan: _onBarcodeScan,
                onImport: () => _importCodes(_scannedCodes),
                onClear: () => setState(() => _scannedCodes.clear()),
              ),
              _TextImportTab(
                controller: _textController,
                onImport: () {
                  final codes = provider.parseTrackCodes(_textController.text);
                  _importCodes(codes);
                },
              ),
              _FileImportTab(onImport: _importFromFile),
            ],
          ),
        ),

        // Error display
        if (provider.error != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrandPalette.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: BrandPalette.errorRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: BrandPalette.errorRed),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: provider.clearError,
                  iconSize: 18,
                ),
              ],
            ),
          ),

        // Import result display
        if (provider.importedCargos.isNotEmpty) _ImportResultSection(cargos: provider.importedCargos),
      ],
    );
  }

  void _onBarcodeScan(String code) {
    if (code.isNotEmpty && !_scannedCodes.contains(code)) {
      setState(() => _scannedCodes.add(code));
      _barcodeController.clear();
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _importCodes(List<String> codes) async {
    if (codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track code оруулна уу')),
      );
      return;
    }

    final provider = context.read<ChinaCargoProvider>();
    final result = await provider.importTrackCodes(codes);

    if (mounted) {
      if (result.success > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.success} бараа амжилттай бүртгэгдлээ'),
            backgroundColor: BrandPalette.successGreen,
          ),
        );
        _textController.clear();
        setState(() => _scannedCodes.clear());
      }
      if (result.hasErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.failed} бараа бүртгэхэд алдаа гарлаа'),
            backgroundColor: BrandPalette.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv', 'xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      final provider = context.read<ChinaCargoProvider>();
      final codes = provider.parseTrackCodes(content);

      if (codes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Файлд track code олдсонгүй')),
          );
        }
        return;
      }

      await _importCodes(codes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Файл унших алдаа: $e')),
        );
      }
    }
  }
}

/// Camera scanner tab using mobile_scanner
class _CameraScannerTab extends StatefulWidget {
  const _CameraScannerTab({
    required this.scannedCodes,
    required this.onScan,
    required this.onImport,
    required this.onClear,
  });

  final List<String> scannedCodes;
  final void Function(String) onScan;
  final VoidCallback onImport;
  final VoidCallback onClear;

  @override
  State<_CameraScannerTab> createState() => _CameraScannerTabState();
}

class _CameraScannerTabState extends State<_CameraScannerTab> {
  MobileScannerController? _controller;
  bool _isScanning = true;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        // Debounce - ignore same code within 2 seconds
        final now = DateTime.now();
        if (_lastScannedCode == code &&
            _lastScanTime != null &&
            now.difference(_lastScanTime!).inSeconds < 2) {
          return;
        }

        _lastScannedCode = code;
        _lastScanTime = now;

        if (!widget.scannedCodes.contains(code)) {
          widget.onScan(code);
          _showScanSuccess(code);
        }
      }
    }
  }

  void _showScanSuccess(String code) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                code,
                style: const TextStyle(fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: BrandPalette.successGreen,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera preview
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E9F2), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Scanner
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),

                // Scan overlay
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: BrandPalette.logoOrange,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                // Controls
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Toggle flash
                      _ScannerButton(
                        icon: Icons.flash_on,
                        label: 'Flash',
                        onPressed: () => _controller?.toggleTorch(),
                      ),
                      // Toggle camera
                      _ScannerButton(
                        icon: Icons.cameraswitch,
                        label: 'Камер',
                        onPressed: () => _controller?.switchCamera(),
                      ),
                      // Pause/Resume
                      _ScannerButton(
                        icon: _isScanning ? Icons.pause : Icons.play_arrow,
                        label: _isScanning ? 'Зогсоох' : 'Үргэлжлүүлэх',
                        onPressed: () {
                          setState(() {
                            _isScanning = !_isScanning;
                            if (_isScanning) {
                              _controller?.start();
                            } else {
                              _controller?.stop();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Scanned count badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.scannedCodes.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Scanned codes list
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9F2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.scannedCodes.length} код уншуулсан',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.scannedCodes.isNotEmpty)
                      TextButton.icon(
                        onPressed: widget.onClear,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Цэвэрлэх'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: widget.scannedCodes.isEmpty
                      ? Center(
                          child: Text(
                            'Barcode уншуулна уу',
                            style: TextStyle(color: BrandPalette.mutedText),
                          ),
                        )
                      : ListView.builder(
                          itemCount: widget.scannedCodes.length,
                          itemBuilder: (context, index) {
                            final code = widget.scannedCodes[widget.scannedCodes.length - 1 - index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: BrandPalette.softBlueBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${widget.scannedCodes.length - index}.',
                                    style: TextStyle(
                                      color: BrandPalette.mutedText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      code,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        // Import button
        if (widget.scannedCodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onImport,
                icon: const Icon(Icons.upload),
                label: Text('${widget.scannedCodes.length} код бүртгэх'),
                style: FilledButton.styleFrom(
                  backgroundColor: BrandPalette.logoOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ScannerButton extends StatelessWidget {
  const _ScannerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarcodeTab extends StatelessWidget {
  const _BarcodeTab({
    required this.controller,
    required this.focusNode,
    required this.scannedCodes,
    required this.onScan,
    required this.onImport,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> scannedCodes;
  final void Function(String) onScan;
  final VoidCallback onImport;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Info text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrandPalette.electricBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: BrandPalette.electricBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'USB/Bluetooth barcode scanner ашиглан уншуулна уу',
                    style: TextStyle(color: BrandPalette.electricBlue, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Barcode input field (for scanner input)
          TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Barcode уншуулна уу...',
              prefixIcon: const Icon(Icons.qr_code_scanner),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E9F2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E9F2)),
              ),
            ),
            onSubmitted: (value) {
              onScan(value.trim());
              focusNode.requestFocus();
            },
          ),
          const SizedBox(height: 16),

          // Scanned codes list
          Expanded(
            child: scannedCodes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShipIcon(
                          ShipAssets.boxReturn,
                          size: 64,
                          color: BrandPalette.mutedText.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Barcode уншуулна уу',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: BrandPalette.mutedText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Уншуулсан code-ууд энд харагдана',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: BrandPalette.mutedText,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${scannedCodes.length} код уншуулсан',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: onClear,
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Цэвэрлэх'),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: scannedCodes.length,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE5E9F2)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}.',
                                  style: TextStyle(
                                    color: BrandPalette.mutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    scannedCodes[index],
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    scannedCodes.removeAt(index);
                                    (context as Element).markNeedsBuild();
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Import button
          if (scannedCodes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.upload),
                  label: Text('${scannedCodes.length} код бүртгэх'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandPalette.logoOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TextImportTab extends StatelessWidget {
  const _TextImportTab({
    required this.controller,
    required this.onImport,
  });

  final TextEditingController controller;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChinaCargoProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Track code-уудыг мөр бүрт нэг эсвэл таслалаар тусгаарлан оруулна уу...\n\nЖишээ:\nTC123456789\nTC987654321\nTC111222333',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E9F2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E9F2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: provider.isImporting ? null : onImport,
              icon: provider.isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.upload),
              label: Text(provider.isImporting ? 'Бүртгэж байна...' : 'Бүртгэх'),
              style: FilledButton.styleFrom(
                backgroundColor: BrandPalette.logoOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FileImportTab extends StatelessWidget {
  const _FileImportTab({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChinaCargoProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E9F2),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: BrandPalette.logoOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const ShipIcon(
                    ShipAssets.boxReturn,
                    color: BrandPalette.logoOrange,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Файл оруулах',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TXT, CSV, эсвэл Excel файл сонгоно уу.\nTrack code-ууд мөр бүрт нэг байх ёстой.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BrandPalette.mutedText,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: provider.isImporting ? null : onImport,
                  icon: provider.isImporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.folder_open),
                  label: Text(provider.isImporting ? 'Бүртгэж байна...' : 'Файл сонгох'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandPalette.logoOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportResultSection extends StatelessWidget {
  const _ImportResultSection({required this.cargos});

  final List<CargoModel> cargos;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandPalette.successGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: BrandPalette.successGreen),
              const SizedBox(width: 8),
              Text(
                '${cargos.length} бараа бүртгэгдлээ',
                style: const TextStyle(
                  color: BrandPalette.successGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.read<ChinaCargoProvider>().clearImportedCargos(),
                child: const Text('Хаах'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cargos.take(10).map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                c.trackingNumber,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            )).toList(),
          ),
          if (cargos.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${cargos.length - 10} бусад...',
                style: TextStyle(
                  color: BrandPalette.mutedText,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
