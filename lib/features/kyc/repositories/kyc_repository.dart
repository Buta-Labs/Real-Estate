import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository(FirebaseFirestore.instance, FirebaseStorage.instance);
});

class KycRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  KycRepository(this._firestore, this._storage);

  /// Uploads a document image to Firebase Storage and returns the download URL
  Future<String> uploadDocument({
    required String userId,
    required File file,
    required String documentType, // e.g., 'passport', 'id_card'
  }) async {
    try {
      final ext = file.path.split('.').last;
      final ref = _storage
          .ref()
          .child('kyc_documents')
          .child(userId)
          .child(
            '${documentType}_${DateTime.now().millisecondsSinceEpoch}.$ext',
          );

      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Submits the KYC application data to Firestore
  Future<void> submitApplication({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('kyc_applications').doc(userId).set({
        ...data,
        'userId': userId,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update user profile with 'pending' status for easy access
      await _firestore.collection('users').doc(userId).update({
        'kycStatus': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  /// Gets the current KYC status
  Future<String> getKycStatus(String userId) async {
    try {
      final doc = await _firestore
          .collection('kyc_applications')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data()?['status'] ?? 'none';
      }
      return 'none';
    } catch (e) {
      return 'none'; // Default to none if error or not found
    }
  }
}
