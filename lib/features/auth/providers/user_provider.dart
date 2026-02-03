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
    // Watch the Firestore document for real-time updates
    // UserRepository typically encapsulates this. Let's add a stream method to UserRepository or just fetch once and subscribe.
    // Better: UserRepository.userStream(uid)

    // For now, let's assume we want real-time updates (e.g. KYC status change)
    // We need to add streamUser to UserRepository.
    // If not available, we can just do one-off fetch, but stream is better for "Session Management".

    // Let's assume we will add streamUser to UserRepository.
    yield* ref.watch(userRepositoryProvider).userStream(authUser.uid);
  }
});
