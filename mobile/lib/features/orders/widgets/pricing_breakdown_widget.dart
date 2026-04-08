import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/models/pricing_calculation.dart';
import 'package:core/features/admin/services/pricing_service.dart';
import 'package:flutter/material.dart';

/// Widget showing detailed pricing breakdown
class PricingBreakdownWidget extends StatelessWidget {
  const PricingBreakdownWidget({
    super.key,
    required this.calculation,
  });

  final PricingCalculation calculation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BrandPalette.electricBlue.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with final price
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BrandPalette.electricBlue,
                  BrandPalette.navyBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const Text(
                  'Таны тээврийн төлбөр',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(calculation.finalFeeMnt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        calculation.method == 'volume' ? Icons.view_in_ar : Icons.scale,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        calculation.methodLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Breakdown details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _BreakdownRow(
                  icon: Icons.scale_outlined,
                  label: 'Жин',
                  value: '${calculation.weightKg.toStringAsFixed(2)} кг',
                ),
                const SizedBox(height: 12),
                _BreakdownRow(
                  icon: Icons.view_in_ar_outlined,
                  label: 'Эзлэхүүн',
                  value: _formatVolume(calculation.volumeCbm),
                ),
                if (calculation.isFragile) ...[
                  const SizedBox(height: 12),
                  _BreakdownRow(
                    icon: Icons.warning_amber_rounded,
                    label: 'Эмзэг бараа',
                    value: 'Тийм (+30,000₮/м³)',
                    valueColor: BrandPalette.logoOrange,
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                // Calculation comparison
                _ComparisonRow(
                  label: 'Жингээр тооцсон',
                  value: _formatPrice(calculation.weightBasedFeeMnt),
                  isSelected: calculation.method == 'weight',
                  formula: '${calculation.weightKg.toStringAsFixed(2)} кг × ${PricingRates.pricePerKg}₮',
                ),
                const SizedBox(height: 10),
                _ComparisonRow(
                  label: 'Эзлэхүүнээр тооцсон',
                  value: _formatPrice(calculation.volumeBasedFeeMnt),
                  isSelected: calculation.method == 'volume',
                  formula: '${calculation.volumeCbm.toStringAsFixed(4)} м³ × ${calculation.isFragile ? PricingRates.pricePerCbmFragile : PricingRates.pricePerCbm}₮',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BrandPalette.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BrandPalette.successGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: BrandPalette.successGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Жин болон эзлэхүүний аль өндөр тооцоог сонгоно',
                          style: TextStyle(
                            color: BrandPalette.successGreen.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted₮';
  }

  String _formatVolume(double volumeCbm) {
    if (volumeCbm >= 1) {
      return '${volumeCbm.toStringAsFixed(3)} м³';
    }
    final liters = volumeCbm * 1000;
    if (liters >= 1) {
      return '${liters.toStringAsFixed(2)} л';
    }
    final cmCubed = volumeCbm * 1000000;
    return '${cmCubed.toStringAsFixed(0)} см³';
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: BrandPalette.electricBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: BrandPalette.electricBlue, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: BrandPalette.mutedText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? BrandPalette.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.formula,
  });

  final String label;
  final String value;
  final bool isSelected;
  final String formula;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? BrandPalette.electricBlue.withValues(alpha: 0.08) : BrandPalette.softBlueBackground,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: BrandPalette.electricBlue.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: BrandPalette.electricBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? BrandPalette.electricBlue : BrandPalette.mutedText,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: isSelected ? BrandPalette.electricBlue : BrandPalette.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formula,
            style: TextStyle(
              color: BrandPalette.mutedText.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
