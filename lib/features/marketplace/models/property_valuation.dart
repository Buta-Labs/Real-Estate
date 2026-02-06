class PropertyValuation {
  final String propertyId;
  final double purchasePrice;
  final double renovationCost;
  final double acquisitionFee; // 3% of purchase price
  final double totalRaiseAmount;

  PropertyValuation({
    required this.propertyId,
    required this.purchasePrice,
    required this.renovationCost,
    required this.acquisitionFee,
    required this.totalRaiseAmount,
  });

  factory PropertyValuation.fromMap(Map<String, dynamic> map) {
    return PropertyValuation(
      propertyId: map['propertyId'] ?? '',
      purchasePrice: (map['purchasePrice'] ?? 0).toDouble(),
      renovationCost: (map['renovationCost'] ?? 0).toDouble(),
      acquisitionFee: (map['acquisitionFee'] ?? 0).toDouble(),
      totalRaiseAmount: (map['totalRaiseAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'purchasePrice': purchasePrice,
      'renovationCost': renovationCost,
      'acquisitionFee': acquisitionFee,
      'totalRaiseAmount': totalRaiseAmount,
    };
  }

  // Calculate acquisition fee as 3% of purchase price
  static double calculateAcquisitionFee(double purchasePrice) {
    return purchasePrice * 0.03;
  }

  // Calculate total raise amount
  static double calculateTotalRaise(
    double purchasePrice,
    double renovationCost,
    double acquisitionFee,
  ) {
    return purchasePrice + renovationCost + acquisitionFee;
  }
}
