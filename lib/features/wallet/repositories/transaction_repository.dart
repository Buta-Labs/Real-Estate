import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(FirebaseFirestore.instance);
});

final transactionHistoryProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, uid) {
      return ref.watch(transactionRepositoryProvider).getTransactions(uid);
    });

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  Future<void> logTransaction({
    required String uid,
    required String type, // 'deposit', 'withdraw', 'invest', 'sell'
    required double amount,
    required String currency, // 'USDT', 'USDC', 'USD'
    String status = 'completed',
    String? hash,
    String? description,
    // Contract generation metadata
    String? contractUrl,
    String? contractHash,
    bool? tier2Acknowledged,
    DateTime? tier2AcknowledgmentTime,
  }) async {
    try {
      final transactionData = <String, dynamic>{
        'type': type,
        'amount': amount,
        'currency': currency,
        'status': status,
        'hash': hash,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add contract metadata if provided
      if (contractUrl != null) transactionData['contractUrl'] = contractUrl;
      if (contractHash != null) transactionData['contractHash'] = contractHash;
      if (tier2Acknowledged != null)
        transactionData['tier2Acknowledged'] = tier2Acknowledged;
      if (tier2AcknowledgmentTime != null) {
        transactionData['tier2AcknowledgmentTime'] = Timestamp.fromDate(
          tier2AcknowledgmentTime,
        );
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .add(transactionData);
    } catch (e) {
      debugPrint('Failed to log transaction: $e');
      throw Exception('Failed to log transaction: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getTransactions(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data,
              // Normalize timestamp locally if needed, but passing raw data is flexible
              'timestamp': data['timestamp'] ?? Timestamp.now(),
            };
          }).toList();
        });
  }
}
