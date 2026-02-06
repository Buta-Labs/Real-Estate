import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/features/wallet/providers/wallet_provider.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/features/wallet/repositories/transaction_repository.dart';

final walletCurrencyProvider = NotifierProvider<WalletCurrencyNotifier, String>(
  WalletCurrencyNotifier.new,
);

class WalletCurrencyNotifier extends Notifier<String> {
  @override
  String build() => 'USDT';

  void setCurrency(String currency) {
    state = currency;
  }
}

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(walletCurrencyProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background Ambience
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlue.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, ref),
                  const SizedBox(height: 24),
                  _buildCurrencyToggle(ref, currency),
                  const SizedBox(height: 24),
                  _buildBalanceCard(currency),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                  const SizedBox(height: 32),
                  _buildRecentActivity(ref),
                  const SizedBox(height: 100), // Bottom padding for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    // Watch wallet address
    final walletAddress = ref.watch(walletAddressProvider);
    final isConnected = walletAddress != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF065F2C)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundDark,
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBk6GvdZ7dVCqVPj7siDqGbO8x-7_eydJ7GHaVVg62GtcotFKPd-Czy_WgLh4y6PFi4xc9B_k_o6dz2BaK7xuRCzOCDmi2yqzwzcqzOu0_Oq93ay_r3xKkUmghFilDw9eq4HwnXNE9zXcJf1WLjqW7o2MAvnfMvWBYLnoVqXQUdWjBB7z7Uqv5EQtaPfqpLfTwryT0RBqxk70DwvBDKvwfbiCK5z3Zzfs856RSVOzm5EQ9YnfRH0nAs-Lai5XplpvR7kdpMfcYH9A',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isConnected
                      ? '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}'
                      : 'Not Connected',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isConnected)
          ElevatedButton(
            onPressed: () => connectWallet(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Connect',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          )
        else
          IconButton(
            onPressed: () {}, // Navigate to convert or wallet details
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildCurrencyToggle(WidgetRef ref, String currentCurrency) {
    return Center(
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyButton(
              ref,
              label: 'USDT',
              isActive: currentCurrency == 'USDT',
            ),
            _buildCurrencyButton(
              ref,
              label: 'USDC',
              isActive: currentCurrency == 'USDC',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyButton(
    WidgetRef ref, {
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => ref.read(walletCurrencyProvider.notifier).setCurrency(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.black
                : Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String currency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified_user,
                      size: 16,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final balanceAsync = ref.watch(walletBalanceProvider);
                    return balanceAsync.when(
                      data: (balance) => Text(
                        '\$$balance', // Actually showing MATIC count for now as per "native balance"
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => const Text(
                        'Error',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final usdcAsync = ref.watch(usdcBalanceProvider);
                          return usdcAsync.when(
                            data: (val) => _buildSubBalance(
                              '\$$val',
                              'INVESTABLE',
                              Colors.black.withValues(alpha: 0.2),
                              AppColors.primary,
                            ),
                            loading: () => const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (_, _) => _buildSubBalance(
                              '\$0.00',
                              'INVESTABLE',
                              Colors.black.withValues(alpha: 0.2),
                              AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSubBalance(
                        '\$4,500.00',
                        'WITHDRAWABLE',
                        Colors.black.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubBalance(
    String amount,
    String label,
    Color bgColor,
    Color labelColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.push('/deposit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_card, size: 20),
                SizedBox(width: 8),
                Text('Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.push('/withdraw'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_outward, size: 20),
                SizedBox(width: 8),
                Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const SizedBox();

    final historyAsync = ref.watch(transactionHistoryProvider(user.uid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No recent transactions',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: transactions.map((tx) {
                final type = tx['type'] as String;
                final amount = tx['amount'] as double;
                final currency = tx['currency'] as String;
                final timestamp = tx['timestamp'];
                final status = tx['status'] as String;

                // Determine Icon & Color
                IconData icon;
                Color iconColor;
                String title;
                String amountPrefix = '';

                if (type == 'deposit') {
                  icon = Icons.arrow_downward;
                  iconColor = AppColors.primary;
                  title = 'Deposit';
                  amountPrefix = '+';
                } else if (type == 'withdraw') {
                  icon = Icons.arrow_upward;
                  iconColor = Colors.orange;
                  title = 'Withdrawal';
                  amountPrefix = '-';
                } else {
                  icon = Icons.swap_horiz;
                  iconColor = Colors.white;
                  title = type.toUpperCase();
                }

                String dateStr = 'Recent';
                // Simple date parsing if needed, similar to Login History
                if (timestamp != null) {
                  try {
                    final date = (timestamp as dynamic).toDate();
                    final now = DateTime.now();
                    final diff = now.difference(date);
                    if (diff.inDays == 0) {
                      dateStr = 'Today';
                    } else if (diff.inDays == 1) {
                      dateStr = 'Yesterday';
                    } else {
                      dateStr = '${date.month}/${date.day}';
                    }
                  } catch (_) {}
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityItem(
                    icon: icon,
                    iconColor: iconColor,
                    title: title,
                    subtitle: '$status • $dateStr',
                    amount: '$amountPrefix\$$amount $currency',
                    amountColor: type == 'deposit'
                        ? AppColors.primary
                        : Colors.white,
                    status: status.toUpperCase(),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text(
            'Error loading history: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required String status,
  }) {
    final isPrimary = iconColor == AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
