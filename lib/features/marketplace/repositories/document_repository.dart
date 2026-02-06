import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_document.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});

final propertyDocumentsProvider =
    StreamProvider.family<List<PropertyDocument>, String>((ref, propertyId) {
      return ref
          .watch(documentRepositoryProvider)
          .getPropertyDocuments(propertyId);
    });

class DocumentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all documents for a specific property
  Stream<List<PropertyDocument>> getPropertyDocuments(String propertyId) {
    return _firestore
        .collection('propertyDocuments')
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PropertyDocument.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get documents by category for a property
  Stream<List<PropertyDocument>> getDocumentsByCategory(
    String propertyId,
    String category,
  ) {
    return _firestore
        .collection('propertyDocuments')
        .where('propertyId', isEqualTo: propertyId)
        .where('documentType', isEqualTo: category)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PropertyDocument.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Add a new document (used by admin panel)
  Future<void> addDocument(PropertyDocument document) async {
    await _firestore.collection('propertyDocuments').add(document.toMap());
  }

  /// Delete a document
  Future<void> deleteDocument(String documentId) async {
    await _firestore.collection('propertyDocuments').doc(documentId).delete();
  }

  /// Get document count for a property
  Future<int> getDocumentCount(String propertyId) async {
    final snapshot = await _firestore
        .collection('propertyDocuments')
        .where('propertyId', isEqualTo: propertyId)
        .get();
    return snapshot.docs.length;
  }
}
