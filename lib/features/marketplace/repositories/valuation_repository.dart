import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orre_mmc_app/features/marketplace/models/valuation_model.dart';

class ValuationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of property valuations
  Stream<List<Valuation>> getValuations(String propertyId) {
    return _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('valuations')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Valuation.fromFirestore(doc)).toList(),
        );
  }

  /// Calculate Token Net Asset Value (NAV)
  double calculateTokenNAV(double currentValuation, int totalTokens) {
    if (totalTokens <= 0) return 0;
    return currentValuation / totalTokens;
  }

  /// Calculate appreciation percentage from initial to current valuation
  double calculateAppreciation(
    double currentValuation,
    double initialValuation,
  ) {
    if (initialValuation <= 0) return 0;
    return ((currentValuation - initialValuation) / initialValuation) * 100;
  }

  /// Calculate progress to exit target (for Growth tier)
  double calculateExitProgress({
    required double currentValuation,
    required double initialValuation,
    required double targetValuation,
  }) {
    if (targetValuation <= initialValuation) return 0;
    final totalGrowthNeeded = targetValuation - initialValuation;
    final currentGrowth = currentValuation - initialValuation;
    return (currentGrowth / totalGrowthNeeded) * 100;
  }

  /// Calculate yield on cost (for Rental tier)
  double calculateYieldOnCost({
    required double annualRent,
    required double userInvestment,
  }) {
    if (userInvestment <= 0) return 0;
    return (annualRent / userInvestment) * 100;
  }

  /// Calculate implied nightly rate (for Owner-Stay tier)
  double calculateImpliedNightlyRate({
    required double monthlyRent,
    required double currentValuation,
    required double initialValuation,
  }) {
    if (initialValuation <= 0) return 0;
    final baseNightlyRate = monthlyRent / 30;
    final valuationMultiplier = currentValuation / initialValuation;
    return baseNightlyRate * valuationMultiplier;
  }

  /// Add a new valuation (Admin only)
  Future<void> addValuation({
    required String propertyId,
    required DateTime date,
    required double valuationAmount,
    required String source,
    required double changePercent,
    String? documentUrl,
  }) async {
    final valuation = Valuation(
      id: '',
      date: date,
      valuationAmount: valuationAmount,
      source: source,
      changePercent: changePercent,
      documentUrl: documentUrl,
    );

    // Add to subcollection
    await _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('valuations')
        .add(valuation.toMap());

    // Update property's current valuation and last appraisal date
    await _firestore.collection('properties').doc(propertyId).update({
      'currentValuation': valuationAmount,
      'lastAppraisalDate': date.toIso8601String(),
    });
  }

  /// Get the most recent valuation
  Future<Valuation?> getLatestValuation(String propertyId) async {
    final snapshot = await _firestore
        .collection('properties')
        .doc(propertyId)
        .collection('valuations')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Valuation.fromFirestore(snapshot.docs.first);
  }
}
