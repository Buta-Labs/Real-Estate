import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/marketplace/models/monthly_financial_report.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_valuation.dart';

final financialRepositoryProvider = Provider<FinancialRepository>((ref) {
  return FinancialRepository();
});

final propertyFinancialReportsProvider =
    StreamProvider.family<List<MonthlyFinancialReport>, String>((
      ref,
      propertyId,
    ) {
      return ref
          .watch(financialRepositoryProvider)
          .getPropertyFinancialReports(propertyId);
    });

final propertyValuationProvider =
    FutureProvider.family<PropertyValuation?, String>((ref, propertyId) {
      return ref
          .watch(financialRepositoryProvider)
          .getPropertyValuation(propertyId);
    });

class FinancialRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all financial reports for a property
  Stream<List<MonthlyFinancialReport>> getPropertyFinancialReports(
    String propertyId,
  ) {
    return _firestore
        .collection('financialReports')
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MonthlyFinancialReport.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get property valuation
  Future<PropertyValuation?> getPropertyValuation(String propertyId) async {
    final doc = await _firestore
        .collection('propertyValuations')
        .doc(propertyId)
        .get();

    if (!doc.exists) return null;
    return PropertyValuation.fromMap(doc.data()!);
  }

  /// Add a financial report (used by admin)
  Future<void> addFinancialReport(MonthlyFinancialReport report) async {
    await _firestore.collection('financialReports').add(report.toMap());
  }

  /// Set property valuation (used by admin)
  Future<void> setPropertyValuation(PropertyValuation valuation) async {
    await _firestore
        .collection('propertyValuations')
        .doc(valuation.propertyId)
        .set(valuation.toMap());
  }

  /// Get latest financial report for a property
  Future<MonthlyFinancialReport?> getLatestReport(String propertyId) async {
    final snapshot = await _firestore
        .collection('financialReports')
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('reportDate', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MonthlyFinancialReport.fromMap(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  /// Calculate total dividends from all reports
  Future<double> calculateTotalDividends(String propertyId) async {
    final snapshot = await _firestore
        .collection('financialReports')
        .where('propertyId', isEqualTo: propertyId)
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      final report = MonthlyFinancialReport.fromMap(doc.data(), doc.id);
      total += report.netDistributableIncome;
    }
    return total;
  }
}
