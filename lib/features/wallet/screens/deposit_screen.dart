import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Deposit'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withOpacity(0.9),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bank Transfer selected')),
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
              onTap: () {
                // Navigate to Crypto Deposit flow (mock)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crypto Deposit selected')),
                );
              },
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Orre MMC acts as a bridge for fractional real estate. All investments are secured by physical property deeds.',
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.8),
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
          color: Colors.white.withOpacity(0.05),
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
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
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
                        : Colors.white.withOpacity(0.1),
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
