import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/core/services/biometric_service.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  bool _isBiometricsEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final enabled = await ref
        .read(biometricServiceProvider)
        .isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricsEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    setState(() => _isLoading = true);
    final bioService = ref.read(biometricServiceProvider);

    if (value) {
      // Enabling: Require password to store it
      final password = await _showPasswordDialog();
      if (password != null) {
        final email = ref.read(authRepositoryProvider).currentUser?.email;
        if (email != null) {
          final success = await bioService.enableBiometrics(email, password);
          if (success) {
            setState(() => _isBiometricsEnabled = true);
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Face ID Enabled')));
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to enable Face ID')),
              );
            }
          }
        }
      }
    } else {
      // Disabling
      await bioService.disableBiometrics();
      setState(() => _isBiometricsEnabled = false);
    }
    setState(() => _isLoading = false);
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text(
          'Confirm Password',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          'Security & Privacy',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Face ID Toggle
          SwitchListTile(
            contentPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            tileColor: Colors.white.withValues(alpha: 0.05),
            secondary: const Icon(
              Icons.face,
              color: AppColors.primary,
              size: 32,
            ),
            title: Text(
              'Biometric Login',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Use Face ID / Touch ID to log in securely.',
                style: GoogleFonts.manrope(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
            ),
            value: _isBiometricsEnabled,
            onChanged: _isLoading ? null : _toggleBiometrics,
            activeThumbColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            tileColor: Colors.white.withValues(alpha: 0.05),
            leading: const Icon(
              Icons.phonelink_lock,
              color: AppColors.primary,
              size: 32,
            ),
            title: Text(
              'SMS Multi-factor Authentication',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Add an extra layer of security to your account using SMS verification.',
                style: GoogleFonts.manrope(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
            onTap: () => context.push('/mfa-enrollment'),
          ),
        ],
      ),
    );
  }
}
