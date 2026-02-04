import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/features/auth/controllers/auth_controller.dart';
import 'package:orre_mmc_app/router/app_router.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class MfaVerificationScreen extends ConsumerStatefulWidget {
  final MultiFactorResolver resolver;

  const MfaVerificationScreen({super.key, required this.resolver});

  @override
  ConsumerState<MfaVerificationScreen> createState() =>
      _MfaVerificationScreenState();
}

class _MfaVerificationScreenState extends ConsumerState<MfaVerificationScreen> {
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _isCodeSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Automatically send code if possible or wait for user?
    // Let's wait for user to confirm so they know what's happening.
  }

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    try {
      final verificationId = await ref
          .read(authControllerProvider.notifier)
          .startMfaSignInVerification(widget.resolver);
      setState(() {
        _verificationId = verificationId;
        _isCodeSent = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('SMS code sent!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending code: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null) return;
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .resolveMfaSignIn(
            widget.resolver,
            _verificationId!,
            _codeController.text.trim(),
          );

      // Update MFA state locally to trigger immediate redirect/update
      ref.read(mfaProvider.notifier).setVerified(true);

      // Navigation should be handled by the auth state listener in the parent or main wrapper
      // But since we are here, we might need to manually pop or let the stream listener handle it.
      // If sign in is successful, the authStateChanges stream will fire.

      // However, usually we can just pop this screen or replace it with dashboard?
      // Better to just let the main router redirect based on auth state?
      // Or explicitly go to dashboard.
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract hints
    final hints = widget.resolver.hints
        .whereType<PhoneMultiFactorInfo>()
        .toList();
    final hintText = hints.isNotEmpty
        ? 'Code will be sent to ${hints.first.phoneNumber}'
        : 'Unknown number';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Security Verification', style: GoogleFonts.manrope()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.go('/login'), // If they cancel, go back to login
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Two-Step Verification',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hintText,
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 32),

            if (!_isCodeSent) ...[
              Text(
                'Click below to send the verification code.',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              _buildButton('Send SMS Code', _sendCode),
            ] else ...[
              _buildInputField('SMS CODE', Icons.lock_clock, _codeController),
              const SizedBox(height: 24),
              _buildButton('Verify', _verifyCode),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
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
            ? const CircularProgressIndicator(color: Colors.black)
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
