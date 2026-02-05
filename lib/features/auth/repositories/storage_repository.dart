import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(FirebaseStorage.instance);
});

class StorageRepository {
  final FirebaseStorage _storage;

  StorageRepository(this._storage);

  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ext = imageFile.path.split('.').last;
      final ref = _storage.ref().child('profile_images').child('$userId.$ext');

      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
