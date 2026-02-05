import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/features/wallet/repositories/transaction_repository.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_result.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/core/services/toast_service.dart';

class DepositScreen extends ConsumerWidget {
  const DepositScreen({super.key});

  void _showCryptoDepositSheet(BuildContext context, WidgetRef ref) async {
    // Get address
    final repository = ref.read(blockchainRepositoryProvider);
    final result = await repository.connectWallet(context);

    String address = '';
    if (result is Success<String>) {
      address = result.data;
    } else {
      if (context.mounted) {
        ToastService().showError(context, 'Please connect wallet first');
      }
      return;
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Deposit Crypto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Send ETH, USDT, or USDC (Base) to this address.',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.qr_code_2, size: 200, color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Wallet Address',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Courier',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppColors.primary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address));
                      ToastService().showSuccess(context, 'Address copied!');
                      context.pop();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Orre Deposit'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Choose Deposit Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select your preferred way to fund your Orre account.',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildOptionCard(
              context,
              title: 'Bank Transfer (USD)',
              description:
                  'Direct transfer from local or international accounts.',
              icon: Icons.account_balance,
              isRecommended: true,
              onTap: () {
                // Navigate to Bank Transfer flow (mock)
                final user = ref.read(authRepositoryProvider).currentUser;
                if (user != null) {
                  ref
                      .read(transactionRepositoryProvider)
                      .logTransaction(
                        uid: user.uid,
                        type: 'deposit',
                        amount: 5000.00, // Mock amount
                        currency: 'USD',
                        status: 'pending',
                        description: 'Bank Transfer Deposit',
                      );
                }
                ToastService().showSuccess(
                  context,
                  'Bank Transfer initiated (Mock Deposit Logged)',
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'Crypto Deposit',
              description:
                  'Transfer USDT/USDC directly via ERC20 or TRC20 networks.',
              icon: Icons.currency_bitcoin,
              onTap: () => _showCryptoDepositSheet(context, ref),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Orre acts as a bridge for fractional real estate. All investments are secured by physical property deeds.',
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended ? AppColors.primary : Colors.transparent,
            width: isRecommended ? 1 : 0,
          ),
        ),
        child: Stack(
          children: [
            if (isRecommended)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'FAST & SECURE',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isRecommended
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isRecommended ? AppColors.primary : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isRecommended
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Select ${title.split(' ')[0]}',
                      style: TextStyle(
                        color: isRecommended ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
