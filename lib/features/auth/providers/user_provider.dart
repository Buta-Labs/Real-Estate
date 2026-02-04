import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/auth/models/user_model.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/features/auth/repositories/user_repository.dart';

final userProvider = StreamProvider<UserModel?>((ref) async* {
  final authUserAsync = ref.watch(authStateProvider);

  // If loading or error, default to null or rethrow
  if (authUserAsync.isLoading) {
    yield null;
    return; // Wait for data
  }

  if (authUserAsync.hasError) {
    yield null;
    return;
  }

  final authUser = authUserAsync.value;

  if (authUser == null) {
    yield null;
  } else {
    // 1. Create a fallback UserModel from Auth data
    final fallbackUser = UserModel(
      uid: authUser.uid,
      email: authUser.email ?? '',
      displayName: authUser.displayName,
      photoUrl: authUser.photoURL,
      phoneNumber: authUser.phoneNumber,
    );

    // 2. Watch Firestore, but catch permission errors/nulls
    try {
      final userStream = ref
          .watch(userRepositoryProvider)
          .userStream(authUser.uid);

      await for (final firestoreUser in userStream) {
        if (firestoreUser != null) {
          yield firestoreUser;
        } else {
          // If doc doesn't exist yet, use fallback
          yield fallbackUser;
        }
      }
    } catch (e) {
      // If Firestore fails (e.g. permission denied), yield the fallback
      yield fallbackUser;
    }
  }
});
