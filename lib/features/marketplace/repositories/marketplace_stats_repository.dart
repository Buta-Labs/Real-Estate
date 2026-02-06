import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/marketplace/controllers/marketplace_controller.dart';

class MarketplaceStats {
  final double volume24h;
  final int totalListings;
  final double averageYield;

  MarketplaceStats({
    required this.volume24h,
    required this.totalListings,
    required this.averageYield,
  });
}

final marketplaceStatsProvider = FutureProvider<MarketplaceStats>((ref) async {
  // Watch properties list for real-time sync with UI
  final properties = await ref.watch(propertyListProvider.future);
  final repository = MarketplaceStatsRepository();

  // Calculate Listings and Yield from active properties
  final activeListings = properties.where((p) => p.available > 0).toList();
  final totalListings = activeListings.length;

  double totalYield = 0;
  int yieldCount = 0;
  for (final p in activeListings) {
    if (p.yieldRate > 0) {
      totalYield += p.yieldRate;
      yieldCount++;
    }
  }

  final averageYield = yieldCount > 0 ? totalYield / yieldCount : 0.0;

  // Volume is a separate check that might fail (often due to permissions)
  // We wrap it so it doesn't break the basic stats
  double volume24h = 0;
  try {
    volume24h = await repository.getVolume24h();
  } catch (e) {
    // Only log, don't crash the whole stats block
  }

  return MarketplaceStats(
    volume24h: volume24h,
    totalListings: totalListings,
    averageYield: averageYield,
  );
});

class MarketplaceStatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> getVolume24h() async {
    final twentyFourHoursAgo = DateTime.now().subtract(
      const Duration(hours: 24),
    );

    final transactionsSnapshot = await _firestore
        .collection('transactions')
        .where(
          'timestamp',
          isGreaterThan: twentyFourHoursAgo.millisecondsSinceEpoch,
        )
        .where('type', isEqualTo: 'purchase')
        .get();

    double volume = 0;
    for (final doc in transactionsSnapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final tokenPrice = (data['tokenPrice'] ?? 0).toDouble();
      volume += amount * tokenPrice;
    }
    return volume;
  }

  // Deprecated: Using provider-based calculation for sync accuracy
  Future<MarketplaceStats> getStats() async {
    final volume = await getVolume24h();
    return MarketplaceStats(
      volume24h: volume,
      totalListings: 0,
      averageYield: 0,
    );
  }
}
