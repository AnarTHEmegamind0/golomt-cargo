import 'dart:io';

import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/core/networking/models/cargo_model.dart';
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
    this.onRecordWeight,
    this.onRecordDimensions,
    this.onShip,
    this.onArrive,
    this.isProcessing = false,
  });

  final CargoModel cargo;
  final Future<bool> Function(String? imagePath)? onReceive;
  final Future<bool> Function(int weightGrams, int baseShippingFeeMnt)?
  onRecordWeight;
  final Future<bool> Function({
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    required bool isFragile,
    int? overrideFeeMnt,
  })?
  onRecordDimensions;
  final VoidCallback? onShip;
  final VoidCallback? onArrive;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role ?? UserRole.customer;
    final canPrice = role == UserRole.admin && onRecordDimensions != null;

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

    if (cargo.status == CargoStatus.receivedChina && onRecordWeight != null) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 8));
      }
      buttons.add(
        Expanded(
          child: _ActionButton(
            label: 'Жин бүртгэх',
            icon: Icons.scale_rounded,
            color: BrandPalette.logoOrange,
            onPressed: isProcessing ? null : () => _showWeightDialog(context),
          ),
        ),
      );
    }

    if (canPrice) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 8));
      }
      buttons.add(
        Expanded(
          child: _ActionButton(
            label: 'Хэмжээ / үнэ',
            icon: Icons.calculate_outlined,
            color: BrandPalette.navyBlue,
            onPressed: isProcessing
                ? null
                : () => _showDimensionsDialog(context),
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

  void _showWeightDialog(BuildContext context) {
    final weightController = TextEditingController(
      text: cargo.weightGrams != null ? cargo.weightKg.toStringAsFixed(2) : '',
    );
    final feeController = TextEditingController(
      text: cargo.baseShippingFeeMnt?.toString() ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Жин бүртгэх'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              decoration: const InputDecoration(
                labelText: 'Жин (кг)',
                hintText: '0.00',
                suffixText: 'кг',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Суурь тээврийн төлбөр',
                hintText: '0',
                suffixText: '₮',
              ),
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
              final weightKg = double.tryParse(weightController.text);
              final fee = int.tryParse(feeController.text);
              if (weightKg == null || weightKg <= 0) {
                return;
              }

              final computedFee = ((weightKg * 2000).ceil())
                  .clamp(2000, 1 << 31)
                  .toInt();
              final success = await onRecordWeight!(
                (weightKg * 1000).round(),
                fee ?? computedFee,
              );
              if (context.mounted && success) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  void _showDimensionsDialog(BuildContext context) {
    if (onRecordDimensions == null) {
      return;
    }

    final heightController = TextEditingController(
      text: cargo.heightCm?.toString() ?? '',
    );
    final widthController = TextEditingController(
      text: cargo.widthCm?.toString() ?? '',
    );
    final lengthController = TextEditingController(
      text: cargo.lengthCm?.toString() ?? '',
    );
    final overrideFeeController = TextEditingController(
      text: cargo.overrideFeeMnt?.toString() ?? '',
    );
    var isFragile = cargo.isFragile;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Хэмжээ, үнэ бүртгэх'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: lengthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Урт (см)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Өргөн (см)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Өндөр (см)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: overrideFeeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Эцсийн үнэ override',
                    hintText: 'Хоосон орхиж болно',
                    suffixText: '₮',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: isFragile,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Эмзэг бараа'),
                  onChanged: (value) => setState(() => isFragile = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Болих'),
            ),
            FilledButton(
              onPressed: () async {
                final heightCm = int.tryParse(heightController.text);
                final widthCm = int.tryParse(widthController.text);
                final lengthCm = int.tryParse(lengthController.text);
                final overrideFee = overrideFeeController.text.trim().isEmpty
                    ? null
                    : int.tryParse(overrideFeeController.text.trim());

                if (heightCm == null ||
                    widthCm == null ||
                    lengthCm == null ||
                    heightCm <= 0 ||
                    widthCm <= 0 ||
                    lengthCm <= 0) {
                  return;
                }

                final success = await onRecordDimensions!(
                  heightCm: heightCm,
                  widthCm: widthCm,
                  lengthCm: lengthCm,
                  isFragile: isFragile,
                  overrideFeeMnt: overrideFee,
                );
                if (context.mounted && success) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Хадгалах'),
            ),
          ],
        ),
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
