import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  double _amount = 5000;
  static const double _maxLimit = 24500;
  static const double _tokenPrice = 10;
  static const double _feeRate = 0.005;

  @override
  Widget build(BuildContext context) {
    final tokenCount = (_amount / _tokenPrice).floor();
    final processingFee = _amount * _feeRate;
    final total = _amount + processingFee;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark.withOpacity(0.9),
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDW_8XT1xp__oKoroaTrAyK-nrl5py2E4KgHmZXkz_-UOFE1XTGzBirA1JNBp3xI_wEq1zH59rnebYDylCuK0WiF6aFWTWYaJExYWn0F4s0IBCf4bli_ro_Mdrku7G0lN83t6-nUOXqVhhSFT20Kwn-1SNk7op__xC8VP342jbcFQe-7h7IDKZSb9UyNpO6we5s-vP3RvTGR6kLqmtJ4lpQgIuYzBzdEvFFrQEt5F0o4gv_kx1QlHGA3IZ1p_Kxf8MgzgpuVrfstQ',
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
                  'Orre MMC - Penthouse Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Fractional Ownership • 12.5% APY',
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
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
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
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
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
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Text('Confirm Investment'),
            label: const Icon(Icons.arrow_forward),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
