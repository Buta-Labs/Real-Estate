import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/auth/models/user_model.dart';
import 'package:orre_mmc_app/features/auth/repositories/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    ref.read(userRepositoryProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  AuthRepository(this._firebaseAuth, this._userRepository);

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _userRepository.saveUser(
          UserModel(
            uid: credential.user!.uid,
            email: email,
            createdAt: DateTime.now(),
          ),
        );
      }

      return credential;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // MFA: Enroll a phone number
  Future<String> enrollMfa(String phoneNumber) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to enroll in MFA.');
    }

    final session = await user.multiFactor.getSession();
    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      multiFactorSession: session,
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      codeAutoRetrievalTimeout: (_) {},
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(_handleError(e));
      },
    );

    return completer.future;
  }

  Future<void> verifyMfaEnrollment(
    String verificationId,
    String smsCode,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User must be logged in.');

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
    await user.multiFactor.enroll(assertion);
  }

  Future<UserCredential> resolveMfaSignIn(
    MultiFactorResolver resolver,
    String verificationId,
    String smsCode,
  ) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
    return await resolver.resolveSignIn(assertion);
  }

  // Helper to trigger SMS for MFA Sign In
  Future<String> startMfaSignInVerification(
    MultiFactorResolver resolver,
  ) async {
    if (resolver.hints.isEmpty) {
      throw Exception('No MFA hints available.');
    }
    final hint = resolver.hints.first as PhoneMultiFactorInfo;

    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      multiFactorInfo: hint,
      multiFactorSession: resolver.session,
      verificationCompleted: (_) {},
      codeAutoRetrievalTimeout: (_) {},
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(_handleError(e));
      },
    );

    return completer.future;
  }

  Exception _handleError(dynamic e) {
    if (e is FirebaseAuthException) {
      if (e.code == 'network-request-failed') {
        return Exception('Network error. Please check your connection.');
      }
      // Pass through the MFA required exception so layers above can handle it
      if (e.code == 'second-factor-required') {
        // The actual code is usually handled via proper flow
        // Actually in FirebaseAuth, normally it throws a specific exception structure
        // but we want to bubble up the raw exception or a wrapped one that contains the resolver
        return e;
      }

      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found for that email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('The account already exists for that email.');
        case 'invalid-email':
          return Exception('The email address is not valid.');
        case 'weak-password':
          return Exception('The password provided is too weak.');
        case 'invalid-verification-code':
          return Exception('The SMS code is invalid.');
        case 'invalid-verification-id':
          return Exception('The verification ID is invalid.');
        default:
          return Exception(e.message ?? 'An unknown error occurred.');
      }
    }
    return Exception('An unknown error occurred: $e');
  }
}
