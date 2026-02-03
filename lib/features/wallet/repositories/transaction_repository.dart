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
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .add({
            'type': type,
            'amount': amount,
            'currency': currency,
            'status': status,
            'hash': hash,
            'description': description,
            'timestamp': FieldValue.serverTimestamp(),
          });
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
