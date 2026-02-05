import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/features/auth/controllers/auth_controller.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/router/app_router.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class MfaEnrollmentScreen extends ConsumerStatefulWidget {
  const MfaEnrollmentScreen({super.key});

  @override
  ConsumerState<MfaEnrollmentScreen> createState() =>
      _MfaEnrollmentScreenState();
}

class _MfaEnrollmentScreenState extends ConsumerState<MfaEnrollmentScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _isCodeSent = false;
  bool _isLoading = false;

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (mounted) context.go('/login');
  }

  void _showCustomToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.redAccent : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _showCustomToast('Please enter a valid phone number', isError: true);
        return;
      }

      final verificationId = await ref
          .read(authControllerProvider.notifier)
          .enrollMfa(phone);

      setState(() {
        _verificationId = verificationId;
        _isCodeSent = true;
      });
      if (mounted) {
        _showCustomToast('Verification code sent');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('No user found') ||
            errorMsg.contains('user-not-found')) {
          // Handle stale user state
          _showCustomToast(
            'Session expired. Please sign in again.',
            isError: true,
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) _signOut();
          return;
        }
        _showCustomToast(errorMsg.replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null) return;
    setState(() => _isLoading = true);

    try {
      final code = _codeController.text.trim();
      if (code.isEmpty) {
        _showCustomToast('Please enter the code', isError: true);
        return;
      }

      await ref
          .read(authControllerProvider.notifier)
          .verifyMfaEnrollment(_verificationId!, code);

      // Update MFA state locally to trigger immediate redirect/update
      ref.read(mfaProvider.notifier).setVerified(true);

      if (mounted) {
        _showCustomToast('Secure Account Enabled!');
        context.go('/dashboard'); // Explicit nav to ensure router update
      }
    } catch (e) {
      if (mounted) {
        _showCustomToast('Verification Failed: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMfaVal = ref.watch(mfaProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;
    final isEnrolled = (hasMfaVal == true) || authRepo.hasMfaEnrolled(user);

    // Show "MFA Active" UI if already enrolled and not in the "sending code" phase
    if (isEnrolled && !_isCodeSent) {
      final rawPhone = authRepo.getEnrolledPhoneNumber(user);
      String maskedPhone = rawPhone ?? 'Protected';
      if (maskedPhone.length > 7 && rawPhone != null) {
        maskedPhone =
            '${maskedPhone.substring(0, 3)} **** ${maskedPhone.substring(maskedPhone.length - 2)}';
      }

      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Stack(
          children: [
            // Background Glows
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassContainer(
                      borderRadius: BorderRadius.circular(32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status Icon with Pulse-like decoration
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    width: 2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shield_rounded,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Security is Active',
                            style: GoogleFonts.manrope(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your account is fully protected with two-factor SMS authentication.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.grey[400],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Phone Display Box
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.phone_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VERIFIED NUMBER',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[500],
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      maskedPhone,
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildButton('Update Phone Number', () {
                            setState(() => _isCodeSent = false);
                            _phoneController.text = ''; // Clear for new number
                          }),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              // Optional: Implement disable logic if needed
                              _showCustomToast(
                                'Contact support to disable MFA for security reasons.',
                                isError: true,
                              );
                            },
                            child: Text(
                              'Disable 2FA',
                              style: GoogleFonts.manrope(
                                color: Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Enable SMS MFA', style: GoogleFonts.manrope()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
            label: Text(
              'Logout',
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure your account',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We require a phone number for all accounts to ensure platform security.',
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 32),
            if (!_isCodeSent) ...[
              _buildInputField(
                'PHONE NUMBER',
                Icons.phone,
                _phoneController,
                placeholder: '+1 555 123 4567',
              ),
              const SizedBox(height: 24),
              _buildButton('Send Code', _sendCode),
            ] else ...[
              _buildInputField(
                'PHONE NUMBER',
                Icons.phone,
                _phoneController,
                enabled: false,
              ),
              const SizedBox(height: 16),
              _buildInputField('SMS CODE', Icons.lock_clock, _codeController),
              const SizedBox(height: 24),
              _buildButton('Verify & Enable', _verifyCode),
              TextButton(
                onPressed: () => setState(() => _isCodeSent = false),
                child: const Center(child: Text('Change Phone Number')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller, {
    String? placeholder,
    bool enabled = true,
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
            enabled: enabled,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.grey[400], size: 20),
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
