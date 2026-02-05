import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/core/services/biometric_service.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/features/auth/repositories/user_repository.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/router/app_router.dart';

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

  void _showLoginActivity() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) =>
            _LoginActivitySheet(scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Security & Privacy',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundDark.withValues(alpha: 0.8),
              AppColors.surface.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
          children: [
            const _SectionHeader(title: 'PROTECTION'),
            const SizedBox(height: 16),
            _SecurityCard(
              icon: Icons.face_unlock_outlined,
              title: 'Biometric Login',
              subtitle: 'Use Face ID / Touch ID to log in securely.',
              trailing: Switch(
                value: _isBiometricsEnabled,
                onChanged: _isLoading ? null : _toggleBiometrics,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.white10,
              ),
              statusLabel: _isBiometricsEnabled ? 'ENABLED' : 'DISABLED',
              statusColor: _isBiometricsEnabled
                  ? AppColors.primary
                  : Colors.grey,
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                final hasMfaVal = ref.watch(mfaProvider);
                final user = ref.read(authRepositoryProvider).currentUser;
                final hasPhone =
                    user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty;
                final isProtected = (hasMfaVal == true) || hasPhone;

                return _SecurityCard(
                  icon: Icons.phonelink_lock_rounded,
                  title: 'Two-Factor (SMS)',
                  subtitle: isProtected
                      ? 'Your account is protected with SMS verification.'
                      : 'Add an extra layer of security with SMS verification.',
                  onTap: () => context.push('/mfa-enrollment'),
                  statusLabel: isProtected ? 'PROTECTED' : 'ENABLE',
                  statusColor: isProtected ? AppColors.primary : Colors.grey,
                  showChevron: true,
                );
              },
            ),
            const SizedBox(height: 40),
            const _SectionHeader(title: 'ACCOUNT HISTORY'),
            const SizedBox(height: 16),
            _SecurityCard(
              icon: Icons.history_rounded,
              title: 'Login Activity',
              subtitle: 'View recent sign-in locations and devices.',
              onTap: _showLoginActivity,
              showChevron: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primary.withValues(alpha: 0.7),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? statusLabel;
  final Color? statusColor;
  final bool showChevron;

  const _SecurityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.statusLabel,
    this.statusColor,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (statusLabel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (statusColor ?? AppColors.primary)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusLabel!,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor ?? AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
            if (showChevron && trailing == null)
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LoginActivitySheet extends ConsumerWidget {
  final ScrollController scrollController;

  const _LoginActivitySheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return const SizedBox();

    final historyAsync = ref.watch(loginHistoryProvider(user.uid));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Login Activity',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent account access',
            style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.white12),
                        const SizedBox(height: 16),
                        Text(
                          'No login activity recorded yet.',
                          style: GoogleFonts.manrope(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: history.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final timestamp = item['timestamp'];
                    final method = item['method'] as String;

                    String dateStr = 'Unknown date';
                    if (timestamp != null) {
                      try {
                        final date =
                            (timestamp as dynamic).toDate() as DateTime;
                        // Format: Feb 4, 2026 at 14:13
                        final months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        dateStr =
                            '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                      } catch (e) {
                        dateStr = timestamp.toString();
                      }
                    }

                    IconData methodIcon = Icons.login;
                    if (method.toLowerCase().contains('google')) {
                      methodIcon = Icons.g_mobiledata;
                    }
                    if (method.toLowerCase().contains('email')) {
                      methodIcon = Icons.email_outlined;
                    }
                    if (method.toLowerCase().contains('phone')) {
                      methodIcon = Icons.phone_android;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              methodIcon,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Signed in via ${method.toUpperCase()}',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: GoogleFonts.manrope(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
