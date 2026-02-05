import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/dashboard/providers/pinned_views_provider.dart';
import 'package:orre_mmc_app/features/auth/providers/user_provider.dart';
import 'package:orre_mmc_app/features/wallet/providers/wallet_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedViews = ref.watch(pinnedViewsProvider);
    final userAsync = ref.watch(userProvider);
    final walletBalanceAsync = ref.watch(walletBalanceProvider);

    final user = userAsync.valueOrNull;
    final displayName =
        user?.displayName ?? user?.email.split('@')[0] ?? 'User';
    final kycStatus = user?.kycStatus ?? 'none';
    final balance = walletBalanceAsync.valueOrNull ?? '0.00';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
            floating: true,
            pinned: true,
            elevation: 0,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    Text(
                      displayName,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 100,
            ), // Bottom padding for nav bar
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // KYC Warning Banner
                if (kycStatus != 'verified') ...[
                  GestureDetector(
                    onTap: () => context.push('/kyc-verification'),
                    child: GlassContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            kycStatus == 'pending'
                                ? Icons.hourglass_top
                                : Icons.warning_amber_rounded,
                            color: kycStatus == 'pending'
                                ? Colors.orange
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kycStatus == 'pending'
                                      ? 'Verification Pending'
                                      : 'Verify Your Identity',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  kycStatus == 'pending'
                                      ? 'Your documents are under review.'
                                      : 'Complete KYC to unlock full access.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Portfolio Value Card
                GlassContainer(
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'WALLET BALANCE',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Icon(
                            Icons.account_balance_wallet,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$balance POL',
                        style: GoogleFonts.manrope(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+0.0%', // Placeholder for now until we track history
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '24h Change',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Shortcuts (Pinned Views)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Shortcuts',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showCustomizeShortcuts(context, ref),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text(
                        'CUSTOMIZE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (pinnedViews.isNotEmpty)
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: pinnedViews.length,
                    itemBuilder: (context, index) {
                      return _buildShortcutCard(context, pinnedViews[index]);
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Center(
                      child: Text(
                        'No shortcuts yet. Tap to pin pages.',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),

                // Investment Worlds
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Investment Worlds',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/marketplace'),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Rental World
                _buildInvestmentWorldCard(
                  title: 'Rental World',
                  subtitle: 'Consistent monthly cash flow',
                  tag: 'Passive Income',
                  icon: Icons.key,
                  color: const Color(0xFF0BDA5E),
                  image:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxmdkjaKgLr00a3L9aKK7IMPbp7q6J9Bwc6xpWyoM_9-8pohSkPjWW80zOdEu7t0Y1zcXXOo807IV3ufmMJPLNoaqrTe4xjX9VmXcK6nAHn2LfyKyNFOPO_x42iG6JxDYApmGam7FxYCXeA1IFjNbgvWO_54V5BNks2qkjKblxKVvh0s5FLnqt-4RPMK8WjZENtHdqBTYZpuFDkNiJbZj8qUrg8pJQ2IYmtdqP5A9EnNHV35L4Qz_5vgz-N4V7HrQ-vRhosjasKw',
                ),

                const SizedBox(height: 16),

                // Growth World
                _buildInvestmentWorldCard(
                  title: 'Growth World',
                  subtitle: 'Max capital appreciation focus',
                  tag: 'Appreciation',
                  icon: Icons.trending_up,
                  color: AppColors.primary,
                  image:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC7_ufblomaprRMlA3OtnZIY_yxPdEvsXfRqCPCtxiJKNuIomnocsJv85FwIMwyLJvMtYMMPDV3LwXRYsCwKIZ98GWBJv3TXz_2Y_l3oWtYqaS-h1VA4o9VoW755INBSLMEAAdv15m_-e2dhB7g-dicGXz5CfEVA5kAeLzvrCqthug_fNqSJUvUZYyw6AUeeX6zzvCeL4ij78dlNckQNb-GU6Lu1LC9j0293rclFFHX-0JuUE973m0SSYPIvGHNUP1r9EdPwJTohw',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentWorldCard({
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color color,
    required String image,
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.9),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        tag.toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard(BuildContext context, String viewId) {
    // Map viewId to icon and label
    IconData icon;
    String label;
    switch (viewId) {
      case 'analytics':
        icon = Icons.insights;
        label = 'Analytics';
        break;
      case 'learning':
        icon = Icons.school;
        label = 'Learning';
        break;
      case 'insights':
        icon = Icons.lightbulb;
        label = 'Insights';
        break;
      case 'referrals':
        icon = Icons.emoji_events;
        label = 'Referrals';
        break;
      case 'marketplace':
        icon = Icons.storefront;
        label = 'Invest';
        break;
      case 'governance':
        icon = Icons.gavel;
        label = 'Governance';
        break;
      case 'documents':
        icon = Icons.folder_shared;
        label = 'Documents';
        break;
      default:
        icon = Icons.explore;
        label = viewId;
    }

    return GestureDetector(
      onTap: () {
        if (viewId == 'marketplace') {
          context.go('/marketplace');
        } else {
          context.push('/$viewId');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101622),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey[400], size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Quick Access',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomizeShortcuts(BuildContext context, WidgetRef ref) {
    final allShortcuts = [
      {'id': 'analytics', 'label': 'Analytics', 'icon': Icons.insights},
      {'id': 'learning', 'label': 'Learning', 'icon': Icons.school},
      {'id': 'insights', 'label': 'Insights', 'icon': Icons.lightbulb},
      {'id': 'referrals', 'label': 'Referrals', 'icon': Icons.emoji_events},
      {'id': 'marketplace', 'label': 'Invest', 'icon': Icons.storefront},
      {'id': 'governance', 'label': 'Governance', 'icon': Icons.gavel},
      {'id': 'documents', 'label': 'Documents', 'icon': Icons.folder_shared},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final currentPins = ref.watch(pinnedViewsProvider);
                return Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Customize Shortcuts',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pin your most used pages to the dashboard.',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: allShortcuts.length,
                          itemBuilder: (context, index) {
                            final shortcut = allShortcuts[index];
                            final isPinned = currentPins.contains(
                              shortcut['id'] as String,
                            );
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                shortcut['icon'] as IconData,
                                color: isPinned
                                    ? AppColors.primary
                                    : Colors.grey[600],
                              ),
                              title: Text(
                                shortcut['label'] as String,
                                style: TextStyle(
                                  color: isPinned
                                      ? Colors.white
                                      : Colors.grey[400],
                                ),
                              ),
                              trailing: Switch(
                                value: isPinned,
                                activeThumbColor: AppColors.primary,
                                onChanged: (value) {
                                  ref
                                      .read(pinnedViewsProvider.notifier)
                                      .togglePin(shortcut['id'] as String);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
