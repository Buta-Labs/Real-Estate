import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_result.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/core/services/toast_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  double _amount = 5000;
  static const double _maxLimit = 24500;
  static const double _tokenPrice = 10;
  static const double _feeRate = 0.005;
  bool _isLoading = false;

  // Hardcoded for MVP Demonstration - matches "The Orion Penthouse" seeded data
  static const String _demoContractAddress =
      '0x1234567890123456789012345678901234567890';

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(blockchainRepositoryProvider);

      // 1. Check if wallet is connected (simple check)
      final balance = await repository.getNativeBalance();
      if (balance == "0.00") {
        // Try to connect if not connected
        final result = await repository.connectWallet(context);
        if (result is Failure) {
          _showError('Please connect your wallet first.');
          setState(() => _isLoading = false);
          return;
        }
      }

      // 2. Perform Purchase
      final result = await repository.purchaseToken(
        _demoContractAddress,
        _amount,
        onStatusChanged: (status) {
          ToastService().showInfo(context, status);
        },
      );

      if (result is Success) {
        if (mounted) context.push('/success');
      } else if (result is Failure) {
        _showError(
          'Transaction failed: ${(result as Failure).failure.message}',
        );
      }
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ToastService().showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final tokenCount = (_amount / _tokenPrice).floor();
    final processingFee = _amount * _feeRate;
    final total = _amount + processingFee;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Invest',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildAssetContextCard(),
                  const SizedBox(height: 32),
                  _buildAmountInput(tokenCount),
                  const SizedBox(height: 48),
                  _buildSlider(_maxLimit),
                  const SizedBox(height: 24),
                  _buildWalletBalance(_maxLimit),
                ],
              ),
            ),
          ),
          _buildSummaryPanel(processingFee, total),
        ],
      ),
    );
  }

  Widget _buildAssetContextCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBxsR1Uvzzr5Rf008mbOADxpT_xz5mzvQ7Zkaur3EzLxob79FZM2ni_qrdwpycXrJTx07CJigcx3bYQL8YEYuhk6pRcitxavfGKrhgb5yzk6vSHssX9kFqgvm9vcqr9kPCvI4wFJsNTKz6WziTNWU6GoJklFRzq1lZVdzV2mdz3oVD-wDuc6_gWrPK6pSV5YBclX_UA3zvR1DGPhQq902g-boM1BD9RS4sCOAw2Hgqwy9XwheOKGN3TJypIKOrlEVK91rFm51A48A',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Orion Penthouse',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Fractional Ownership • 8.5% Yield',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAmountInput(int tokenCount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              '\$',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            IntrinsicWidth(
              child: TextFormField(
                initialValue: _amount.toInt().toString(),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  final val = double.tryParse(value);
                  if (val != null) {
                    setState(() => _amount = val);
                  }
                },
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.token, color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Text(
                '≈ ${tokenCount.toString()} ORRE Tokens',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(double max) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: const Color(0xFF1C2333),
            thumbColor: Colors.white,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _amount.clamp(0, max),
            min: 0,
            max: max,
            onChanged: (value) => setState(() => _amount = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('\$100', style: TextStyle(color: Colors.grey)),
              Text(
                '\$${max.toInt()}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletBalance(double max) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Balance: \$${max.toInt()} USDT',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        TextButton(
          onPressed: () => setState(() => _amount = max),
          child: const Text(
            'Use Max',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryPanel(double processingFee, double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Investment', style: TextStyle(color: Colors.grey)),
              Text(
                '\$${_amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    'Processing Fee (0.5%)',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.help_outline, color: Colors.grey, size: 14),
                ],
              ),
              Text(
                '\$${processingFee.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.backgroundDark,
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Confirm Investment'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
