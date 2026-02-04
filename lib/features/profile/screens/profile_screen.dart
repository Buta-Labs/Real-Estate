import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/auth/providers/user_provider.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.valueOrNull;

    final displayName =
        user?.displayName ?? user?.email.split('@')[0] ?? 'User';
    final photoUrl = user?.photoUrl;
    final kycStatus = user?.kycStatus ?? 'none';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
            expandedHeight: 280,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.backgroundDark,
                            width: 4,
                          ),
                          image: DecorationImage(
                            image: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : const NetworkImage(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCY0ZlgXp1ZlhT7-z36bX049q9hxHyq13xMEb3mQBmETZCFcbMcJqP0OXIhcMr_g31hey5Xxv97KKKrZ0j9EJV04lYq3kNgwC7NeyX3UfSThQWTOg2NDeyJCMcxB8anWc5PG-8ZgFeDAtWhO55wUju5OQwQZRj4hf6a4JBKqrfw-1fnQP30BCtpjZLyC8nJF4NiEolrTjXfKbggVfs7GM6w35ChaW3t7cfWHx0zEtOdslhwYTjkYxv1fbxWA9pIEzM6egYS69U5fA',
                                      )
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 0,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Logic for settings action if needed, currently just visual or we can navigate to settings screen if separate
                          // Assuming the user wants this to be the "settings" entry point or just visual
                          context.push('/security-settings');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.backgroundDark,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.settings,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'FOUNDER\'S CLUB',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member since ${user?.createdAt?.year ?? 2024}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('ACCOUNT SECURITY'),
                  _buildSectionContainer([
                    _buildSettingsItem(
                      Icons.shield,
                      'Security & Privacy',
                      subtitle: 'Enabled',
                      subtitleColor: AppColors.primary,
                      onTap: () => context.push('/security-settings'),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      Icons.document_scanner,
                      'Verify Identity',
                      subtitle: kycStatus.toUpperCase(),
                      subtitleColor: kycStatus == 'verified'
                          ? AppColors.primary
                          : Colors.orange,
                      onTap: () => context.push('/kyc-verification'),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      Icons.vpn_key,
                      'Guest Access',
                      onTap: () => context.push('/digital-key'),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      Icons.folder_shared,
                      'Legal Documents',
                      onTap: () => context.push('/documents'),
                    ),
                  ]),
                  const SizedBox(height: 32),

                  _buildSectionTitle('COMMUNITY'),
                  _buildSectionContainer([
                    _buildSettingsItem(
                      Icons.emoji_events,
                      'Leaderboard',
                      iconColor: const Color(0xFFFFD700),
                      subtitle: '#42',
                      subtitleColor: AppColors.primary,
                      onTap: () => context.push('/leaderboard'),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      Icons.group_add,
                      'Referrals',
                      onTap: () => context.push('/referrals'),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      Icons.gavel,
                      'Governance Hub',
                      onTap: () => context.push('/governance'),
                    ),
                  ]),
                  const SizedBox(height: 32),

                  _buildSectionTitle('FINANCIALS'),
                  _buildSectionContainer([
                    _buildSettingsItem(
                      Icons.account_balance_wallet,
                      'Wallet Balance',
                      subtitle: '\$142,500.00',
                      subtitleColor: AppColors.primary,
                      onTap: () => context.push('/wallet'),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      Icons.description,
                      'Tax & Reporting',
                      onTap: () => context.push('/tax-reports'),
                    ),
                  ]),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      // Router redirect will handle navigation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                      foregroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.2),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/sitemap'),
                      child: Text(
                        'APP SITEMAP',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return GlassContainer(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withValues(alpha: 0.05));
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    String? subtitle,
    Color? subtitleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: TextStyle(
                color: subtitleColor ?? Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
        ],
      ),
    );
  }
}
