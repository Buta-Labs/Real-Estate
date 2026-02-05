import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/auth/models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final loginHistoryProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, uid) {
      return ref.watch(userRepositoryProvider).getLoginHistory(uid);
    });

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throwException(e);
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throwException(e);
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throwException(e);
    }
  }

  FirebaseFirestore get firestore => _firestore;

  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> logLoginEvent(String uid, String method) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('login_history')
          .add({'timestamp': FieldValue.serverTimestamp(), 'method': method});
    } catch (e) {
      // Don't block login if logging fails, just print or ignore
      debugPrint('Failed to log login event: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getLoginHistory(String uid) async* {
    try {
      final snapshots = _firestore
          .collection('users')
          .doc(uid)
          .collection('login_history')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots();

      await for (final snapshot in snapshots) {
        yield snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'timestamp': data['timestamp'] ?? Timestamp.now(),
            'method': data['method'] ?? 'unknown',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching login history: $e');
      yield <Map<String, dynamic>>[];
    }
  }

  void throwException(dynamic e) {
    throw Exception('UserRepository Error: $e');
  }
}
