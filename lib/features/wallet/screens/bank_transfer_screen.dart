import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';

class BankTransferScreen extends StatelessWidget {
  const BankTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => context.pop(),
            ),
            title: const Text('Bank Transfer Details'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.headset_mic, color: Colors.white54),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transfer Funds',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(text: 'Use the details below. Include the '),
                        TextSpan(
                          text: 'Reference Code',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ' to credit your wallet.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTags(),
                  const SizedBox(height: 16),
                  _buildReferenceCard(),
                  const SizedBox(height: 16),
                  _buildDetailsList(),
                  const SizedBox(height: 24),
                  _buildCopyAllButton(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Funds usually settle within 24-48 hours. Ensure the sender name matches your verified identity.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildFooter(context),
    );
  }

  Widget _buildTags() {
    return Row(
      children: [
        _buildTag(Icons.verified_user, 'Secure'),
        const SizedBox(width: 12),
        _buildTag(Icons.shield, 'Verified'),
      ],
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      color: AppColors.primary.withOpacity(0.05),
      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REFERENCE CODE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CRITICAL',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORRE-9928-XT',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.copy, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList() {
    return Column(
      children: [
        _buildDetailItem(
          'Beneficiary Name',
          'Orre MMC Investments LLC',
          Icons.person,
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          'IBAN / Account',
          'AE76 0000 0000 1234 5678 901',
          Icons.account_balance_wallet,
        ),
        const SizedBox(height: 12),
        _buildDetailItem('SWIFT / BIC', 'NBADAEAAXXX', Icons.public),
        const SizedBox(height: 12),
        _buildDetailItem(
          'Bank Name',
          'First Abu Dhabi Bank',
          Icons.account_balance,
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      color: Colors.white.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white54),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white38, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCopyAllButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.copy, color: Colors.white70),
      label: const Text(
        'Copy All Details',
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.05),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.cloud_upload),
        label: const Text('UPLOAD TRANSFER RECEIPT'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDark,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
