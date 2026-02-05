import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/core/services/biometric_service.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial build logic needed for void state
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmail(email, password),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    File? imageFile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            email: email,
            password: password,
            displayName: displayName,
            imageFile: imageFile,
          ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }

  // ... (previous methods)

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
  }

  Future<void> signInWithWallet(String walletAddress) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithWallet(walletAddress),
    );
  }

  Future<String> startPhoneLogin(String phoneNumber) async {
    return await ref.read(authRepositoryProvider).startPhoneLogin(phoneNumber);
  }

  Future<void> verifyPhoneLogin(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .verifyPhoneLogin(verificationId, smsCode),
    );
  }

  // MFA Methods
  Future<String> enrollMfa(String phoneNumber) async {
    // We don't necessarily want to set global loading state here as it might be a local UI action
    // But for consistency let's just call the repo
    return await ref.read(authRepositoryProvider).enrollMfa(phoneNumber);
  }

  Future<void> verifyMfaEnrollment(
    String verificationId,
    String smsCode,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .verifyMfaEnrollment(verificationId, smsCode),
    );
  }

  Future<String> startMfaSignInVerification(
    MultiFactorResolver resolver,
  ) async {
    return await ref
        .read(authRepositoryProvider)
        .startMfaSignInVerification(resolver);
  }

  Future<void> resolveMfaSignIn(
    MultiFactorResolver resolver,
    String verificationId,
    String smsCode,
  ) async {
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .resolveMfaSignIn(resolver, verificationId, smsCode),
    );
  }

  Future<void> updateProfileImage(File imageFile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).updateProfileImage(imageFile),
    );
  }

  Future<void> signInWithBiometrics() async {
    final bioService = ref.read(biometricServiceProvider);
    final credentials = await bioService.loginWithBiometrics();

    if (credentials != null) {
      final email = credentials['email']!;
      final password = credentials['password']!;
      await signIn(email, password);
    }
  }
}
