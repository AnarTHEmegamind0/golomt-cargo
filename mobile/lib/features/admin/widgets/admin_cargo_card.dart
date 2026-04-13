import 'dart:io';

import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/networking/models/cargo_model.dart';
import 'package:core/features/admin/models/pricing_calculation.dart';
import 'package:core/features/admin/services/pricing_service.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AdminCargoCard extends StatelessWidget {
  const AdminCargoCard({
    super.key,
    required this.cargo,
    this.onReceive,
    this.onRecordPricing,
    this.onShip,
    this.onArrive,
    this.isProcessing = false,
  });

  final CargoModel cargo;
  final Future<bool> Function(String? imagePath)? onReceive;
  /// Unified callback for recording weight, dimensions, and pricing
  final Future<bool> Function({
    required int weightGrams,
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    required bool isFragile,
    int? overrideFeeMnt,
  })? onRecordPricing;
  final VoidCallback? onShip;
  final VoidCallback? onArrive;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role ?? UserRole.customer;
    final canPrice = role == UserRole.admin && onRecordPricing != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cargo.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ShipIcon(
                    cargo.status.shipAsset,
                    color: cargo.status.color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cargo.description?.trim().isNotEmpty == true
                          ? cargo.description!.trim()
                          : 'Cargo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BrandPalette.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      cargo.trackingNumber,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrandPalette.mutedText,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: cargo.status),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.scale_rounded,
                label: cargo.weightGrams != null
                    ? '${cargo.weightKg.toStringAsFixed(2)} кг'
                    : '- кг',
              ),
              _InfoChip(
                icon: Icons.straighten_rounded,
                label: cargo.dimensionsDisplay,
              ),
              _InfoChip(
                icon: Icons.attach_money_rounded,
                label: cargo.finalFeeMnt > 0 ? '${cargo.finalFeeMnt}₮' : '-₮',
              ),
              _InfoChip(
                icon: cargo.paymentStatus == PaymentStatus.paid
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                label: cargo.paymentStatus.label,
                color: cargo.paymentStatus == PaymentStatus.paid
                    ? BrandPalette.successGreen
                    : BrandPalette.logoOrange,
              ),
              if (cargo.shipmentId != null)
                _InfoChip(
                  icon: Icons.local_shipping_outlined,
                  label: 'Shipment',
                  color: BrandPalette.navyBlue,
                ),
              if (cargo.isFragile)
                const _InfoChip(
                  icon: Icons.warning_amber_rounded,
                  label: 'Эмзэг',
                  color: BrandPalette.errorRed,
                ),
            ],
          ),
          const SizedBox(height: 14),
          if ((cargo.customer?.name ?? '').isNotEmpty ||
              (cargo.customer?.email ?? '').isNotEmpty) ...[
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if ((cargo.customer?.name ?? '').isNotEmpty)
                  _InfoChip(
                    icon: Icons.person_outline_rounded,
                    label: cargo.customer!.name,
                  ),
                if ((cargo.customer?.email ?? '').isNotEmpty)
                  _InfoChip(
                    icon: Icons.alternate_email_rounded,
                    label: cargo.customer!.email,
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          _buildActionButtons(context, canPrice),
          if (isProcessing) ...[
            const SizedBox(height: 8),
            const ExcludeSemantics(
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFFE5E9F2),
                valueColor: AlwaysStoppedAnimation(BrandPalette.electricBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool canPrice) {
    final buttons = <Widget>[];

    if (cargo.status == CargoStatus.created && onReceive != null) {
      buttons.add(
        Expanded(
          child: _ActionButton(
            label: 'Хүлээн авах',
            icon: Icons.archive_rounded,
            color: BrandPalette.electricBlue,
            onPressed: isProcessing ? null : () => _showReceiveDialog(context),
          ),
        ),
      );
    }

    // Unified pricing button (weight + dimensions + price)
    if (canPrice && cargo.status == CargoStatus.receivedChina) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 8));
      }
      buttons.add(
        Expanded(
          child: _ActionButton(
            label: 'Үнэ тооцоолох',
            icon: Icons.calculate_rounded,
            color: BrandPalette.electricBlue,
            onPressed: isProcessing
                ? null
                : () => _showPricingCalculatorSheet(context),
          ),
        ),
      );
    }

    if (cargo.status == CargoStatus.receivedChina && onShip != null) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 8));
      }
      buttons.add(
        Expanded(
          child: _ActionButton(
            label: 'Тээвэрлэх',
            icon: Icons.local_shipping_rounded,
            color: BrandPalette.navyBlue,
            onPressed: isProcessing ? null : onShip,
          ),
        ),
      );
    }

    if (cargo.status == CargoStatus.inTransitToMn && onArrive != null) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 8));
      }
      buttons.add(
        Expanded(
          child: _ActionButton(
            label: 'Ирсэн болгох',
            icon: Icons.check_circle_rounded,
            color: BrandPalette.successGreen,
            onPressed: isProcessing ? null : onArrive,
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: buttons);
  }

  void _showPricingCalculatorSheet(BuildContext context) {
    if (onRecordPricing == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PricingCalculatorSheet(
        cargo: cargo,
        onSave: onRecordPricing!,
      ),
    );
  }

  void _showReceiveDialog(BuildContext context) {
    XFile? selectedImage;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Бараа хүлээн авах'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Зураг хавсаргах боломжтой.'),
              const SizedBox(height: 16),
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(selectedImage!.path),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: () async {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() => selectedImage = image);
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Зураг авах'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Болих'),
            ),
            FilledButton(
              onPressed: () async {
                final success = await onReceive?.call(selectedImage?.path);
                if (context.mounted && success == true) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Хүлээн авах'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CargoStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = BrandPalette.mutedText,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

/// Bottom sheet for unified pricing calculation (weight + dimensions + price)
class _PricingCalculatorSheet extends StatefulWidget {
  const _PricingCalculatorSheet({
    required this.cargo,
    required this.onSave,
  });

  final CargoModel cargo;
  final Future<bool> Function({
    required int weightGrams,
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    required bool isFragile,
    int? overrideFeeMnt,
  }) onSave;

  @override
  State<_PricingCalculatorSheet> createState() => _PricingCalculatorSheetState();
}

class _PricingCalculatorSheetState extends State<_PricingCalculatorSheet> {
  final _pricingService = const PricingService();

  late final TextEditingController _weightController;
  late final TextEditingController _lengthController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _overrideController;

  late bool _isFragile;
  PricingCalculation? _calculation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.cargo.weightGrams != null
          ? widget.cargo.weightKg.toStringAsFixed(2)
          : '',
    );
    _lengthController = TextEditingController(
      text: widget.cargo.lengthCm?.toString() ?? '',
    );
    _widthController = TextEditingController(
      text: widget.cargo.widthCm?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.cargo.heightCm?.toString() ?? '',
    );
    _overrideController = TextEditingController(
      text: widget.cargo.overrideFeeMnt?.toString() ?? '',
    );
    _isFragile = widget.cargo.isFragile;

    // Calculate initial price if data exists
    _updateCalculation();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _overrideController.dispose();
    super.dispose();
  }

  int? _getWeightGrams() {
    final weightKg = double.tryParse(_weightController.text);
    if (weightKg == null || weightKg <= 0) return null;
    return (weightKg * 1000).round();
  }

  void _updateCalculation() {
    final weightGrams = _getWeightGrams();
    final lengthCm = int.tryParse(_lengthController.text) ?? 0;
    final widthCm = int.tryParse(_widthController.text) ?? 0;
    final heightCm = int.tryParse(_heightController.text) ?? 0;
    final overrideFee = _overrideController.text.trim().isEmpty
        ? null
        : int.tryParse(_overrideController.text.trim());

    // Need at least weight OR dimensions to calculate
    if ((weightGrams != null && weightGrams > 0) ||
        (lengthCm > 0 && widthCm > 0 && heightCm > 0)) {
      setState(() {
        _calculation = _pricingService.calculateFromCargo(
          weightGrams: weightGrams,
          heightCm: heightCm,
          widthCm: widthCm,
          lengthCm: lengthCm,
          isFragile: _isFragile,
          overrideFeeMnt: overrideFee,
        );
      });
    } else {
      setState(() => _calculation = null);
    }
  }

  Future<void> _save() async {
    final weightGrams = _getWeightGrams();
    final lengthCm = int.tryParse(_lengthController.text);
    final widthCm = int.tryParse(_widthController.text);
    final heightCm = int.tryParse(_heightController.text);
    final overrideFee = _overrideController.text.trim().isEmpty
        ? null
        : int.tryParse(_overrideController.text.trim());

    // Validate - need weight and dimensions
    if (weightGrams == null || weightGrams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Жингийг оруулна уу')),
      );
      return;
    }

    if (lengthCm == null || widthCm == null || heightCm == null ||
        lengthCm <= 0 || widthCm <= 0 || heightCm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Хэмжээсийг бөглөнө үү')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await widget.onSave(
      weightGrams: weightGrams,
      heightCm: heightCm,
      widthCm: widthCm,
      lengthCm: lengthCm,
      isFragile: _isFragile,
      overrideFeeMnt: overrideFee,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: BrandPalette.mutedText.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BrandPalette.electricBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calculate_rounded,
                    color: BrandPalette.electricBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Үнэ тооцоолох',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        widget.cargo.trackingNumber,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BrandPalette.mutedText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Weight input
                  Text(
                    'Жин',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: 'кг',
                      prefixIcon: const Icon(Icons.scale_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => _updateCalculation(),
                  ),
                  const SizedBox(height: 20),

                  // Pricing rates info
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: BrandPalette.electricBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: BrandPalette.electricBlue.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Үнийн тариф',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _RateChip(
                              label: '${PricingRates.pricePerKg}₮/кг',
                              icon: Icons.scale,
                            ),
                            _RateChip(
                              label: '${PricingRates.pricePerCbm}₮/м³',
                              icon: Icons.view_in_ar,
                            ),
                            _RateChip(
                              label: '${PricingRates.pricePerCbmFragile}₮/м³ (эмзэг)',
                              icon: Icons.warning_amber,
                              color: BrandPalette.logoOrange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Dimensions inputs
                  Text(
                    'Хэмжээс (см)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DimensionInput(
                          controller: _lengthController,
                          label: 'Урт',
                          onChanged: (_) => _updateCalculation(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DimensionInput(
                          controller: _widthController,
                          label: 'Өргөн',
                          onChanged: (_) => _updateCalculation(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DimensionInput(
                          controller: _heightController,
                          label: 'Өндөр',
                          onChanged: (_) => _updateCalculation(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fragile toggle
                  Container(
                    decoration: BoxDecoration(
                      color: _isFragile
                          ? BrandPalette.logoOrange.withValues(alpha: 0.1)
                          : BrandPalette.softBlueBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: _isFragile
                          ? Border.all(
                              color: BrandPalette.logoOrange.withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Эмзэг бараа',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Шил, цахилгаан бараа гэх мэт',
                        style: TextStyle(fontSize: 12),
                      ),
                      secondary: Icon(
                        Icons.warning_amber_rounded,
                        color: _isFragile
                            ? BrandPalette.logoOrange
                            : BrandPalette.mutedText,
                      ),
                      value: _isFragile,
                      onChanged: (value) {
                        setState(() => _isFragile = value);
                        _updateCalculation();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Override fee input
                  TextField(
                    controller: _overrideController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Үнэ override (заавал биш)',
                      hintText: 'Автоматаар тооцно',
                      suffixText: '₮',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit_rounded),
                    ),
                    onChanged: (_) => _updateCalculation(),
                  ),
                  const SizedBox(height: 20),

                  // Pricing breakdown
                  if (_calculation != null) ...[
                    _PricingBreakdownCard(calculation: _calculation!),
                    const SizedBox(height: 20),
                  ],

                  // Save button
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(_isSaving ? 'Хадгалж байна...' : 'Хадгалах'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: BrandPalette.electricBlue,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({
    required this.label,
    required this.icon,
    this.color = BrandPalette.electricBlue,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DimensionInput extends StatelessWidget {
  const _DimensionInput({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'см',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onChanged: onChanged,
    );
  }
}

class _PricingBreakdownCard extends StatelessWidget {
  const _PricingBreakdownCard({required this.calculation});

  final PricingCalculation calculation;

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted₮';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BrandPalette.electricBlue,
            BrandPalette.navyBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Final price header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Тээврийн төлбөр',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(calculation.finalFeeMnt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        calculation.method == 'volume'
                            ? Icons.view_in_ar
                            : Icons.scale,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        calculation.methodLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (calculation.hasOverride) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrandPalette.logoOrange.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Override хийсэн',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                _BreakdownRow(
                  label: 'Жингээр тооцсон',
                  value: _formatPrice(calculation.weightBasedFeeMnt),
                  isSelected: calculation.method == 'weight',
                ),
                const SizedBox(height: 8),
                _BreakdownRow(
                  label: 'Эзлэхүүнээр тооцсон',
                  value: _formatPrice(calculation.volumeBasedFeeMnt),
                  isSelected: calculation.method == 'volume',
                ),
                if (calculation.isFragile) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: BrandPalette.logoOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Эмзэг барааны нэмэлт тооцоолсон',
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandPalette.logoOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.isSelected = false,
  });

  final String label;
  final String value;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? BrandPalette.electricBlue.withValues(alpha: 0.1)
            : BrandPalette.softBlueBackground,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(
                color: BrandPalette.electricBlue.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        children: [
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: BrandPalette.electricBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 10),
            ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? BrandPalette.electricBlue : BrandPalette.mutedText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? BrandPalette.electricBlue : BrandPalette.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
