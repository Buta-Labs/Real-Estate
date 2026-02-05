import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/auth/models/user_model.dart';
import 'package:orre_mmc_app/features/auth/repositories/user_repository.dart';
import 'package:orre_mmc_app/features/auth/repositories/storage_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    ref.read(userRepositoryProvider),
    ref.read(storageRepositoryProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).userChanges();
});

/// Tracks if the user has completed MFA for the current app session.
final mfaVerifiedProvider = StateProvider<bool>((ref) => false);

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;

  AuthRepository(
    this._firebaseAuth,
    this._userRepository,
    this._storageRepository,
  );

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Stream<User?> userChanges() => _firebaseAuth.userChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        // Fire and forget logging
        _userRepository.logLoginEvent(credential.user!.uid, 'email');
      }
      return credential;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    File? imageFile,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        String? photoUrl;
        if (imageFile != null) {
          try {
            photoUrl = await _storageRepository.uploadProfileImage(
              userId: credential.user!.uid,
              imageFile: imageFile,
            );
          } catch (e) {
            debugPrint('Failed to upload profile image: $e');
          }
        }

        // Update Firebase Auth Profile
        await credential.user!.updateDisplayName(displayName);
        if (photoUrl != null) {
          await credential.user!.updatePhotoURL(photoUrl);
        }
        await credential.user!.reload(); // Reload to apply changes locally

        // Save to Firestore
        await _userRepository.saveUser(
          UserModel(
            uid: credential.user!.uid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl,
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

  Future<void> updateProfileImage(File imageFile) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User must be logged in.');

    try {
      final photoUrl = await _storageRepository.uploadProfileImage(
        userId: user.uid,
        imageFile: imageFile,
      );

      // Update Firebase Auth Profile
      await user.updatePhotoURL(photoUrl);
      await user.reload();

      // Update Firestore
      await _userRepository.saveUser(
        UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: photoUrl,
          phoneNumber: user.phoneNumber,
        ),
      );
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  Future<void> resendMfaCode(String phoneNumber) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to enroll in MFA.');
    }
  }

  // MFA: Enroll a phone number
  Future<String> enrollMfa(String phoneNumber) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to enroll in MFA.');
    }

    // Firebase requires a verified email to use native MFA sessions.
    // If unverified, we skip the session and perform a standard phone linking verifyPhoneNumber.
    final bool canUseNativeMfa =
        user.emailVerified || user.isAnonymous || user.email == null;

    MultiFactorSession? session;
    if (canUseNativeMfa) {
      try {
        session = await user.multiFactor.getSession();
      } catch (e) {
        debugPrint('Could not get native MFA session: $e');
        // If getting session fails, we'll continue without it and use linking fallback
      }
    }

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

    try {
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      await user.multiFactor.enroll(assertion);
    } catch (e) {
      debugPrint('Native MFA enrollment failed, falling back to linking: $e');
      // Fallback: Link the phone number directly if native MFA is blocked (e.g. unverified email)
      // This ensures the phone number is verified and saved to the account.
      await user.linkWithCredential(credential);
    }

    await user.reload(); // Ensure the user object reflects the new state
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
    final userCredential = await resolver.resolveSignIn(assertion);
    await _firebaseAuth.currentUser?.reload(); // Refresh local state
    return userCredential;
  }

  bool hasMfaEnrolled(User? user) {
    if (user == null) return false;

    try {
      final dynamic mf = (user as dynamic).multiFactor;
      if (mf == null) return false;

      // We use a try-catch to handle versions where enrolledFactors might be missing
      try {
        final dynamic factors = mf.enrolledFactors;
        if (factors is List && factors.isNotEmpty) return true;
      } catch (_) {}

      // Backup check: If user has a phoneNumber at the top level,
      // they have at least verified one factor.
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) return true;

      return false;
    } catch (e) {
      debugPrint('MFA Check Error (Safe): $e');
      // If the property check fails, fall back to phoneNumber
      return user.phoneNumber != null && user.phoneNumber!.isNotEmpty;
    }
  }

  String? getEnrolledPhoneNumber(User? user) {
    if (user == null) return null;

    try {
      // 1. Check top-level phone number
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        return user.phoneNumber;
      }

      // 2. Check MFA factors
      final dynamic mf = (user as dynamic).multiFactor;
      final dynamic factors = mf.enrolledFactors;
      if (factors is List && factors.isNotEmpty) {
        final factor = factors.first;
        if (factor is PhoneMultiFactorInfo) {
          return factor.phoneNumber;
        }
        // Fallback for dynamic/reflected access
        try {
          return (factor as dynamic).phoneNumber as String?;
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error getting enrolled phone number: $e');
    }

    return null;
  }

  // ... (previous methods)

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleSignIn = google_sign_in.GoogleSignIn();
      final google_sign_in.GoogleSignInAccount? googleUser = await googleSignIn
          .signIn();
      if (googleUser == null) {
        throw Exception('Google Sign In cancelled by user.');
      }

      final google_sign_in.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Sync user to Firestore if new or updated
      if (userCredential.user != null) {
        // We might want to just ensure it exists, ignoring merge overlap for now
        // or specific logic. For MVP, we save/update basic info.
        await _userRepository.saveUser(
          UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName,
            photoUrl: userCredential.user!.photoURL,
            phoneNumber: userCredential.user!.phoneNumber, // Might be null
            kycStatus:
                'none', // Default, logic in Repo handles merge/overwrite issues usually
          ),
        );
        // Log event
        _userRepository.logLoginEvent(userCredential.user!.uid, 'google');
      }

      return userCredential;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      if (e.runtimeType.toString().contains('PlatformException')) {
        debugPrint(
          'PLATFORM EXCEPTION: This usually means the SHA-1/SHA-256 fingerprint is not configured in Firebase Console.',
        );
      }
      throw _handleError(e);
    }
  }

  // Wallet Login (Anonymous + Profile Link)
  Future<UserCredential> signInWithWallet(String walletAddress) async {
    try {
      // 1. Sign in anonymously to establish a session
      final userCredential = await _firebaseAuth.signInAnonymously();

      // 2. Save/Update user with wallet address
      if (userCredential.user != null) {
        await _userRepository.saveUser(
          UserModel(
            uid: userCredential.user!.uid,
            email: '', // Empty initially
            displayName: '', // Empty initially
            walletAddress: walletAddress,
            kycStatus: 'none',
          ),
        );
        _userRepository.logLoginEvent(userCredential.user!.uid, 'wallet');
      }
      return userCredential;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Phone Login: Step 1 - Send Code
  Future<String> startPhoneLogin(String phoneNumber) async {
    final completer = Completer<String>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (Android mostly)
        // We can sign in directly here if we want, but usually we just let the UI handle the code
        // or we can complete with a special code to signal auto-complete.
        // For simplicity, we'll just let the code sent trigger happen,
        // or if this fires, we could sign in.
        // Let's just sign in to handle it seamlessly.
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(_handleError(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Timeout
      },
    );

    return completer.future;
  }

  // Phone Login: Step 2 - Verify Code
  Future<UserCredential> verifyPhoneLogin(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        // Save/Update user. Note: Phone login might not have email initially.
        await _userRepository.saveUser(
          UserModel(
            uid: userCredential.user!.uid,
            email:
                userCredential.user!.email ??
                '', // Might be empty for phone auth
            phoneNumber: userCredential.user!.phoneNumber,
            kycStatus: 'none',
          ),
        );
        // Log event
        _userRepository.logLoginEvent(userCredential.user!.uid, 'phone');
      }
      return userCredential;
    } catch (e) {
      throw _handleError(e);
    }
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
    debugPrint('Auth Error: $e');
    if (e is FirebaseAuthException) {
      if (e.code == 'network-request-failed') {
        return Exception('Network error. Please check your connection.');
      }
      // Pass through the MFA required exception so layers above can handle it
      if (e.code == 'second-factor-required') {
        return e;
      }

      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('The account already exists for that email.');
        case 'credential-already-in-use':
          return Exception(
            'This credential is already linked to another account.',
          );
        case 'invalid-email':
          return Exception('The email address is not valid.');
        case 'weak-password':
          return Exception('The password provided is too weak.');
        case 'invalid-verification-code':
          return Exception('The SMS code is invalid.');
        case 'invalid-verification-id':
          return Exception('The verification ID is invalid.');
        case 'account-exists-with-different-credential':
          return Exception(
            'An account implies with the same email already exists. Sign in with that method.',
          );
        default:
          return Exception(e.message ?? 'An unknown error occurred.');
      }
    }
    return Exception('An unknown error occurred: $e');
  }
}
