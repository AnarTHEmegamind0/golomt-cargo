import 'package:core/core/brand_palette.dart';
import 'package:core/features/orders/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cargo card for admin cargo management
class AdminCargoCard extends StatelessWidget {
  const AdminCargoCard({
    super.key,
    required this.cargo,
    this.onReceive,
    this.onRecordWeight,
    this.onShip,
    this.onArrive,
    this.isProcessing = false,
  });

  final Order cargo;
  final VoidCallback? onReceive;
  final void Function(int weightGrams, int baseShippingFeeMnt)? onRecordWeight;
  final VoidCallback? onShip;
  final VoidCallback? onArrive;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
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
          // Header row
          Row(
            children: [
              // Status icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cargo.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    cargo.status.icon,
                    color: cargo.status.color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cargo.productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BrandPalette.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      cargo.trackingCode,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrandPalette.mutedText,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              _StatusBadge(status: cargo.status),
            ],
          ),

          const SizedBox(height: 14),

          // Info row
          Row(
            children: [
              _InfoChip(
                icon: Icons.scale_rounded,
                label: '${cargo.uiWeight.toStringAsFixed(2)} кг',
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: Icons.attach_money_rounded,
                label: '${cargo.uiPrice.toStringAsFixed(0)}₮',
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: cargo.isPaid
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                label: cargo.isPaid ? 'Төлсөн' : 'Төлөөгүй',
                color: cargo.isPaid
                    ? BrandPalette.successGreen
                    : BrandPalette.logoOrange,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action buttons based on status
          _buildActionButtons(context),

          // Loading overlay - wrapped in ExcludeSemantics to avoid Flutter bug
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

  Widget _buildActionButtons(BuildContext context) {
    final List<Widget> buttons = [];

    switch (cargo.status) {
      case OrderStatus.pending:
        if (onReceive != null) {
          buttons.add(
            Expanded(
              child: _ActionButton(
                label: 'Хүлээн авах',
                icon: Icons.archive_rounded,
                color: BrandPalette.electricBlue,
                onPressed: isProcessing ? null : onReceive,
              ),
            ),
          );
        }
        break;

      case OrderStatus.processing:
        if (onRecordWeight != null) {
          buttons.add(
            Expanded(
              child: _ActionButton(
                label: 'Жин бүртгэх',
                icon: Icons.scale_rounded,
                color: BrandPalette.logoOrange,
                onPressed: isProcessing
                    ? null
                    : () => _showWeightDialog(context),
              ),
            ),
          );
        }
        if (onShip != null) {
          if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));
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
        break;

      case OrderStatus.transit:
        if (onArrive != null) {
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
        break;

      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        buttons.add(
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: BrandPalette.softBlueBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  cargo.status == OrderStatus.delivered
                      ? 'Хүргэлт дууссан'
                      : 'Цуцлагдсан',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BrandPalette.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
        break;
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: buttons);
  }

  void _showWeightDialog(BuildContext context) {
    final weightController = TextEditingController(
      text: cargo.weight > 0 ? cargo.weight.toString() : '',
    );
    final feeController = TextEditingController();

    showDialog(
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
                labelText: 'Тээврийн төлбөр',
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
            onPressed: () {
              final weightKg = double.tryParse(weightController.text);
              final fee = int.tryParse(feeController.text);
              if (weightKg != null && weightKg > 0 && fee != null && fee >= 0) {
                Navigator.pop(dialogContext);
                final weightGrams = (weightKg * 1000).round();
                onRecordWeight?.call(weightGrams, fee);
              }
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
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
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? BrandPalette.mutedText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BrandPalette.softBlueBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
