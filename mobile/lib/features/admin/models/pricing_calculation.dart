/// Pricing calculation result model
class PricingCalculation {
  const PricingCalculation({
    required this.weightKg,
    required this.volumeCbm,
    required this.isFragile,
    required this.weightBasedFeeMnt,
    required this.volumeBasedFeeMnt,
    required this.calculatedFeeMnt,
    this.overrideFeeMnt,
    required this.finalFeeMnt,
    required this.method,
  });

  /// Weight in kilograms
  final double weightKg;

  /// Volume in cubic meters
  final double volumeCbm;

  /// Whether the cargo is fragile
  final bool isFragile;

  /// Fee calculated based on weight (weightKg * 2000)
  final int weightBasedFeeMnt;

  /// Fee calculated based on volume (volumeCbm * rate)
  final int volumeBasedFeeMnt;

  /// The calculated fee before any override (max of weight/volume, min 2000)
  final int calculatedFeeMnt;

  /// Admin override fee (if any)
  final int? overrideFeeMnt;

  /// Final fee to charge (override or calculated)
  final int finalFeeMnt;

  /// Which method was used: 'weight' or 'volume'
  final String method;

  /// Check if override was applied
  bool get hasOverride => overrideFeeMnt != null;

  /// Method label in Mongolian
  String get methodLabel {
    return switch (method) {
      'weight' => 'Жингээр',
      'volume' => 'Эзлэхүүнээр',
      _ => method,
    };
  }

  /// Formatted final fee display
  String get finalFeeDisplay {
    if (finalFeeMnt >= 1000) {
      return '${(finalFeeMnt / 1000).toStringAsFixed(0)}K₮';
    }
    return '$finalFeeMnt₮';
  }

  /// Create from JSON
  factory PricingCalculation.fromJson(Map<String, dynamic> json) {
    return PricingCalculation(
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
      volumeCbm: (json['volume_cbm'] as num?)?.toDouble() ?? 0,
      isFragile: json['is_fragile'] as bool? ?? false,
      weightBasedFeeMnt: json['weight_based_fee_mnt'] as int? ?? 0,
      volumeBasedFeeMnt: json['volume_based_fee_mnt'] as int? ?? 0,
      calculatedFeeMnt: json['calculated_fee_mnt'] as int? ?? 0,
      overrideFeeMnt: json['override_fee_mnt'] as int?,
      finalFeeMnt: json['final_fee_mnt'] as int? ?? 0,
      method: json['method'] as String? ?? 'weight',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'weight_kg': weightKg,
      'volume_cbm': volumeCbm,
      'is_fragile': isFragile,
      'weight_based_fee_mnt': weightBasedFeeMnt,
      'volume_based_fee_mnt': volumeBasedFeeMnt,
      'calculated_fee_mnt': calculatedFeeMnt,
      if (overrideFeeMnt != null) 'override_fee_mnt': overrideFeeMnt,
      'final_fee_mnt': finalFeeMnt,
      'method': method,
    };
  }

  @override
  String toString() =>
      'Pricing($finalFeeDisplay by $methodLabel, fragile: $isFragile)';
}
