class DeliveryCandidate {
  const DeliveryCandidate({
    required this.id,
    required this.trackingCode,
    required this.productName,
    required this.status,
  });

  final String id;
  final String trackingCode;
  final String productName;
  final String status;
}
