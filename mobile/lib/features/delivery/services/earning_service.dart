class EarningService {
  const EarningService();

  double estimatedPayout({required double completedTotal, required double feeRate}) {
    return completedTotal * (1 - feeRate);
  }
}
