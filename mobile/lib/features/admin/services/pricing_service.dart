import 'dart:math' as math;

import 'package:core/features/admin/models/pricing_calculation.dart';

/// Pricing rates for cargo shipping
class PricingRates {
  PricingRates._();

  /// Price per kilogram in MNT
  static const int pricePerKg = 2000;

  /// Price per cubic meter in MNT (normal)
  static const int pricePerCbm = 350000;

  /// Price per cubic meter in MNT (fragile)
  static const int pricePerCbmFragile = 380000;

  /// Minimum shipping fee in MNT
  static const int minimumFee = 2000;
}

/// Service for calculating cargo shipping prices
class PricingService {
  const PricingService();

  /// Calculate shipping price based on weight and dimensions
  ///
  /// Rules:
  /// - 1kg = 2,000₮
  /// - 1m³ = 350,000₮ (normal) or 380,000₮ (fragile)
  /// - Minimum fee = 2,000₮
  /// - Uses whichever method (weight or volume) results in higher fee
  ///
  /// [weightKg] - Weight in kilograms
  /// [heightCm] - Height in centimeters
  /// [widthCm] - Width in centimeters
  /// [lengthCm] - Length in centimeters
  /// [isFragile] - Whether the cargo is fragile
  /// [overrideFeeMnt] - Admin override fee (optional)
  PricingCalculation calculate({
    required double weightKg,
    required int heightCm,
    required int widthCm,
    required int lengthCm,
    bool isFragile = false,
    int? overrideFeeMnt,
  }) {
    // Calculate volume in cubic meters
    // cm³ to m³: divide by 1,000,000 (100³)
    final volumeCbm = (heightCm * widthCm * lengthCm) / 1000000.0;

    // Calculate weight-based fee
    final weightBasedFee = (weightKg * PricingRates.pricePerKg).round();

    // Calculate volume-based fee
    final volumeRate =
        isFragile ? PricingRates.pricePerCbmFragile : PricingRates.pricePerCbm;
    final volumeBasedFee = (volumeCbm * volumeRate).round();

    // Use the higher of the two methods
    final calculatedFee = math.max(
      math.max(weightBasedFee, volumeBasedFee),
      PricingRates.minimumFee,
    );

    // Determine which method was used
    final String method;
    if (calculatedFee == PricingRates.minimumFee &&
        weightBasedFee < PricingRates.minimumFee &&
        volumeBasedFee < PricingRates.minimumFee) {
      // Minimum fee applied
      method = 'minimum';
    } else if (volumeBasedFee > weightBasedFee) {
      method = 'volume';
    } else {
      method = 'weight';
    }

    // Final fee is override if provided, otherwise calculated
    final finalFee = overrideFeeMnt ?? calculatedFee;

    return PricingCalculation(
      weightKg: weightKg,
      volumeCbm: volumeCbm,
      isFragile: isFragile,
      weightBasedFeeMnt: weightBasedFee,
      volumeBasedFeeMnt: volumeBasedFee,
      calculatedFeeMnt: calculatedFee,
      overrideFeeMnt: overrideFeeMnt,
      finalFeeMnt: finalFee,
      method: method,
    );
  }

  /// Calculate from cargo model values
  PricingCalculation calculateFromCargo({
    int? weightGrams,
    int? heightCm,
    int? widthCm,
    int? lengthCm,
    bool isFragile = false,
    int? overrideFeeMnt,
  }) {
    return calculate(
      weightKg: (weightGrams ?? 0) / 1000.0,
      heightCm: heightCm ?? 0,
      widthCm: widthCm ?? 0,
      lengthCm: lengthCm ?? 0,
      isFragile: isFragile,
      overrideFeeMnt: overrideFeeMnt,
    );
  }

  /// Format price for display
  String formatPrice(int priceMnt) {
    if (priceMnt >= 1000000) {
      return '${(priceMnt / 1000000).toStringAsFixed(1)}M₮';
    }
    if (priceMnt >= 1000) {
      final formatted = (priceMnt / 1000).toStringAsFixed(0);
      return '${formatted}K₮';
    }
    return '$priceMnt₮';
  }

  /// Format weight for display
  String formatWeight(double weightKg) {
    if (weightKg >= 1) {
      return '${weightKg.toStringAsFixed(2)}кг';
    }
    final grams = (weightKg * 1000).round();
    return '${grams}г';
  }

  /// Format volume for display
  String formatVolume(double volumeCbm) {
    if (volumeCbm >= 1) {
      return '${volumeCbm.toStringAsFixed(2)}м³';
    }
    // Convert to dm³ (liters) for smaller volumes
    final liters = volumeCbm * 1000;
    if (liters >= 1) {
      return '${liters.toStringAsFixed(1)}л';
    }
    // Convert to cm³ for very small volumes
    final cmCubed = volumeCbm * 1000000;
    return '${cmCubed.toStringAsFixed(0)}см³';
  }

  /// Get pricing rates info for display
  Map<String, String> getRatesInfo() {
    return {
      'pricePerKg': '${PricingRates.pricePerKg}₮/кг',
      'pricePerCbm': '${PricingRates.pricePerCbm}₮/м³',
      'pricePerCbmFragile': '${PricingRates.pricePerCbmFragile}₮/м³',
      'minimumFee': '${PricingRates.minimumFee}₮',
    };
  }
}
