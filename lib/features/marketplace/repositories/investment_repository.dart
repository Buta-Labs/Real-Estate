import 'package:flutter_riverpod/flutter_riverpod.dart';

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository();
});

class InvestmentRepository {
  /// Enforced Investment Minimums by Tier
  /// 0: Rental -> $250
  /// 1: Growth -> $1,000
  /// 2: Own Stay -> $5,000
  double getMinimumInvestment(int tierIndex) {
    switch (tierIndex) {
      case 0: // Rental
        return 250.0;
      case 1: // Growth
        return 1000.0;
      case 2: // Own Stay
        return 5000.0;
      default:
        return 250.0;
    }
  }

  /// Fair Usage Benefit Calculation (Tier 3 Only)
  /// DaysAllowed = Floor((UserInvestment / TotalPropertyPrice) * 365)
  int calculateStayDays(double investment, double propertyPrice) {
    if (propertyPrice <= 0) return 0;
    return ((investment / propertyPrice) * 365).floor();
  }

  /// Benefit Lock Logic
  /// "Book Stay" is strictly locked for any investment under $5,000.
  bool isStayBenefitUnlocked(double investment) {
    return investment >= 5000.0;
  }
}
