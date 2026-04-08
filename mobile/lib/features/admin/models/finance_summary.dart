/// Daily revenue data point
class DailyRevenue {
  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.cargoCount,
  });

  final DateTime date;
  final int revenue;
  final int cargoCount;

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: DateTime.parse(json['date'] as String),
      revenue: json['revenue'] as int? ?? 0,
      cargoCount: json['cargo_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'revenue': revenue,
      'cargo_count': cargoCount,
    };
  }

  /// Formatted date display
  String get dateDisplay {
    return '${date.month}/${date.day}';
  }

  /// Formatted revenue display with ₮ symbol
  String get revenueDisplay {
    if (revenue >= 1000000) {
      return '${(revenue / 1000000).toStringAsFixed(1)}M₮';
    }
    if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(0)}K₮';
    }
    return '$revenue₮';
  }
}

/// Financial summary for admin dashboard
class FinanceSummary {
  const FinanceSummary({
    required this.totalRevenueMnt,
    required this.paidAmountMnt,
    required this.unpaidAmountMnt,
    required this.totalCargos,
    required this.paidCargos,
    required this.unpaidCargos,
    required this.avgPricePerKg,
    required this.avgPricePerCbm,
    required this.dailyRevenues,
  });

  final int totalRevenueMnt;
  final int paidAmountMnt;
  final int unpaidAmountMnt;
  final int totalCargos;
  final int paidCargos;
  final int unpaidCargos;
  final double avgPricePerKg;
  final double avgPricePerCbm;
  final List<DailyRevenue> dailyRevenues;

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalRevenueMnt: json['total_revenue_mnt'] as int? ?? 0,
      paidAmountMnt: json['paid_amount_mnt'] as int? ?? 0,
      unpaidAmountMnt: json['unpaid_amount_mnt'] as int? ?? 0,
      totalCargos: json['total_cargos'] as int? ?? 0,
      paidCargos: json['paid_cargos'] as int? ?? 0,
      unpaidCargos: json['unpaid_cargos'] as int? ?? 0,
      avgPricePerKg: (json['avg_price_per_kg'] as num?)?.toDouble() ?? 0.0,
      avgPricePerCbm: (json['avg_price_per_cbm'] as num?)?.toDouble() ?? 0.0,
      dailyRevenues: (json['daily_revenues'] as List<dynamic>?)
              ?.map((e) => DailyRevenue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue_mnt': totalRevenueMnt,
      'paid_amount_mnt': paidAmountMnt,
      'unpaid_amount_mnt': unpaidAmountMnt,
      'total_cargos': totalCargos,
      'paid_cargos': paidCargos,
      'unpaid_cargos': unpaidCargos,
      'avg_price_per_kg': avgPricePerKg,
      'avg_price_per_cbm': avgPricePerCbm,
      'daily_revenues': dailyRevenues.map((e) => e.toJson()).toList(),
    };
  }

  /// Empty summary for initial state
  factory FinanceSummary.empty() {
    return const FinanceSummary(
      totalRevenueMnt: 0,
      paidAmountMnt: 0,
      unpaidAmountMnt: 0,
      totalCargos: 0,
      paidCargos: 0,
      unpaidCargos: 0,
      avgPricePerKg: 0,
      avgPricePerCbm: 0,
      dailyRevenues: [],
    );
  }

  /// Payment collection rate as percentage
  double get collectionRate {
    if (totalRevenueMnt == 0) return 0;
    return (paidAmountMnt / totalRevenueMnt) * 100;
  }

  /// Formatted total revenue display
  String get totalRevenueDisplay {
    if (totalRevenueMnt >= 1000000) {
      return '${(totalRevenueMnt / 1000000).toStringAsFixed(1)}M₮';
    }
    if (totalRevenueMnt >= 1000) {
      return '${(totalRevenueMnt / 1000).toStringAsFixed(0)}K₮';
    }
    return '$totalRevenueMnt₮';
  }

  /// Formatted paid amount display
  String get paidAmountDisplay {
    if (paidAmountMnt >= 1000000) {
      return '${(paidAmountMnt / 1000000).toStringAsFixed(1)}M₮';
    }
    if (paidAmountMnt >= 1000) {
      return '${(paidAmountMnt / 1000).toStringAsFixed(0)}K₮';
    }
    return '$paidAmountMnt₮';
  }

  /// Formatted unpaid amount display
  String get unpaidAmountDisplay {
    if (unpaidAmountMnt >= 1000000) {
      return '${(unpaidAmountMnt / 1000000).toStringAsFixed(1)}M₮';
    }
    if (unpaidAmountMnt >= 1000) {
      return '${(unpaidAmountMnt / 1000).toStringAsFixed(0)}K₮';
    }
    return '$unpaidAmountMnt₮';
  }

  @override
  String toString() =>
      'Finance(total: $totalRevenueDisplay, paid: $paidAmountDisplay)';
}
