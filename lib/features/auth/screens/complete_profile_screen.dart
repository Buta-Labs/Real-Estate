import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _nameController.text = user.displayName!;
        }
        if (user.email != null && user.email!.isNotEmpty) {
          _emailController.text = user.email!;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // 1. If anonymous or missing email/password link, we link
        if (user.isAnonymous && password.isNotEmpty) {
          final credential = EmailAuthProvider.credential(
            email: email,
            password: password,
          );
          await user.linkWithCredential(credential);
        }

        // 2. Update Display Name if it changed or was empty
        if (user.displayName != name) {
          await user.updateDisplayName(name);
        }

        // 3. Update Email if it changed (and not anonymous anymore)
        if (!user.isAnonymous && user.email != email) {
          await user.verifyBeforeUpdateEmail(email);
        }

        await user.reload(); // Apply changes

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Updated Successfully!')),
          );
          // Force refresh
          ref.invalidate(authRepositoryProvider);
          context.go('/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Failed to update profile.';
        if (e.code == 'second-factor-required') {
          final dynamic dynE = e;
          final resolver = dynE.resolver as MultiFactorResolver?;
          if (resolver != null) {
            context.push('/mfa-verification', extra: resolver);
            return;
          }
        }
        if (e.code == 'credential-already-in-use') {
          message = 'This email is already linked to another account.';
        } else if (e.code == 'email-already-in-use') {
          message = 'This email is already in use.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      final user = next.value;
      if (user != null) {
        if (_nameController.text.isEmpty &&
            user.displayName != null &&
            user.displayName!.isNotEmpty) {
          _nameController.text = user.displayName!;
        }
        if (_emailController.text.isEmpty &&
            user.email != null &&
            user.email!.isNotEmpty) {
          _emailController.text = user.email!;
        }
        // Force rebuild if password field needs to hide/show
        if (mounted) setState(() {});
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      'Finish Setting Up',
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'To ensure you can receive legal documents and investment receipts, we require your full name and an email address.',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    GlassContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              hintStyle: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 2) {
                                return 'Enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              hintStyle: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: AppColors.primary,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          if (ref
                                  .read(authRepositoryProvider)
                                  .currentUser
                                  ?.isAnonymous ??
                              true) ...[
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Choose a Password',
                                hintStyle: TextStyle(
                                  color: Colors.grey.withValues(alpha: 0.5),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: AppColors.primary,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 6 chars';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _completeProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : Text(
                                      'Complete Profile',
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
