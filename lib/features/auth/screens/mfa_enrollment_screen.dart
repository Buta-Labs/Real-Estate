import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/features/auth/controllers/auth_controller.dart';
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

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    try {
      final verificationId = await ref
          .read(authControllerProvider.notifier)
          .enrollMfa(_phoneController.text.trim());
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null) return;

    // Set loading via setState for local UI,
    // though the controller also sets global state,
    // mixed approaches can be tricky but let's rely on local for button logic
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .verifyMfaEnrollment(_verificationId!, _codeController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MFA Enabled Successfully!')),
        );
        context.pop(); // Go back
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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Enable SMS MFA', style: GoogleFonts.manrope()),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              'Enter your phone number to receive a verification code.',
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
