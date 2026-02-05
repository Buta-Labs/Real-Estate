import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:orre_mmc_app/features/auth/controllers/auth_controller.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/core/services/biometric_service.dart';
import 'package:orre_mmc_app/core/services/toast_service.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_result.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showBiometricIcon = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final enabled = await ref
        .read(biometricServiceProvider)
        .isBiometricEnabled();
    if (mounted) {
      setState(() => _showBiometricIcon = enabled);
    }
  }

  Future<void> _handleLogin() async {
    await ref
        .read(authControllerProvider.notifier)
        .signIn(_emailController.text.trim(), _passwordController.text.trim());

    if (mounted && ref.read(authControllerProvider).hasError == false) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleBiometricLogin() async {
    await ref.read(authControllerProvider.notifier).signInWithBiometrics();
    if (mounted && ref.read(authControllerProvider).hasError == false) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleGoogleLogin() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (mounted && ref.read(authControllerProvider).hasError == false) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleWalletLogin() async {
    final blockchainRepo = ref.read(blockchainRepositoryProvider);
    ToastService().showInfo(context, 'Connecting to Wallet...');

    final result = await blockchainRepo.connectWallet(context);

    if (mounted) {
      if (result is Success<String>) {
        final address = result.data;
        ToastService().showSuccess(
          context,
          'Wallet Connected: ${address.substring(0, 6)}...',
        );

        await ref
            .read(authControllerProvider.notifier)
            .signInWithWallet(address);

        if (mounted && ref.read(authControllerProvider).hasError == false) {
          context.go('/dashboard');
        }
      } else if (result is Failure<String>) {
        ToastService().showError(
          context,
          'Wallet Connection Failed: ${result.failure.message}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (_, state) {
      if (state.hasError) {
        final error = state.error;
        if (error is FirebaseAuthException &&
            error.code == 'second-factor-required') {
          final resolver = (error as dynamic).resolver as MultiFactorResolver?;
          if (resolver != null) {
            context.push('/mfa-verification', extra: resolver);
            return;
          }
        }
        ToastService().showError(context, state.error.toString());
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB53YcbIZQuktB_lHfjL2ZIKr3UJ10Z3vcOogfM2ZyXWTWYbXA_8cnBtb0esT4tRKq3kKx6nS9Ul04wKSL_EK5IV2S62q-AN-UgPLsMvMM8Hb3cYcBjrUPiy31EUv6LmRPBSKVaOtqj6AWggzM96UXQrc9KhQpbyDXUyrN7OzyZ-tpqdpe4klllC3FGgkKqiAljmJsgR_bna34x5w2k4JIYsapvqS140kI71MrvtfUAEJYjVPpBJIlMZtipr1LvaXyIIlgQsIUCrA',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[900]),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.token,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Orre',
                      style: GoogleFonts.manrope(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ownership, Rights, Returns, Equity',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildInputField(
                      'EMAIL',
                      Icons.mail_outline,
                      _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'PASSWORD',
                      Icons.lock_outline,
                      _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                elevation: 10,
                                shadowColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.black,
                                            ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sign In',
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        if (_showBiometricIcon) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: isLoading ? null : _handleBiometricLogin,
                            child: GlassContainer(
                              borderRadius: BorderRadius.circular(16),
                              padding: const EdgeInsets.all(14),
                              child: Icon(
                                Icons.face_unlock_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _handleGoogleLogin,
                            child: _buildSocialButton(
                              'Google',
                              Icons.g_mobiledata,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: _handleWalletLogin,
                            child: _buildSocialButton(
                              'Wallet',
                              Icons.account_balance_wallet_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "By continuing you agree to Orre MMC's Terms of Service.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Securing connection...',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
        ),
        GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.grey[400], size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
