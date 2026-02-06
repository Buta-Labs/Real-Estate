import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/core/utils/haptic_utils.dart';
import 'package:orre_mmc_app/core/utils/url_launcher_utils.dart';
import 'package:orre_mmc_app/core/services/currency_service.dart';
import 'dart:math' as math;
import 'dart:ui';

class RiskAssessmentScreen extends StatefulWidget {
  const RiskAssessmentScreen({super.key});

  @override
  State<RiskAssessmentScreen> createState() => _RiskAssessmentScreenState();
}

class _RiskAssessmentScreenState extends State<RiskAssessmentScreen> {
  double _usdToAznRate = 1.70;
  double _fxVolatility = 2.3;

  @override
  void initState() {
    super.initState();
    _loadCurrencyData();
  }

  Future<void> _loadCurrencyData() async {
    final rate = await CurrencyService.getUsdToAznRate();
    final volatility = await CurrencyService.getVolatility();
    setState(() {
      _usdToAznRate = rate;
      _fxVolatility = volatility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
            floating: true,
            pinned: true,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => context.pop(),
            ),
            title: const Column(
              children: [
                Text(
                  'RISK ANALYSIS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'The Obsidian Heights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.ios_share), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildRiskMeter(),
                  const SizedBox(height: 40),
                  _buildRiskFactors(),
                  const SizedBox(height: 40),
                  _buildMitigationStrategy(),
                  const SizedBox(height: 100), // Space for sticky footer
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildStickyFooter(context),
    );
  }

  Widget _buildRiskMeter() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          width: 240,
          child: Stack(
            children: [
              // Gauge Background
              CustomPaint(size: const Size(240, 120), painter: _GaugePainter()),
              // Labels
              const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Moderate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Risk Profile Index 4.2/10',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Balanced asset performance with high stability and medium liquidity, optimized for 3-5 year holding periods.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildRiskFactors() {
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.analytics, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Risk Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 1. Market Liquidity (Enhanced)
        _buildGlassMorphismRiskCard(
          title: 'Market Liquidity',
          subtitle: 'P2P marketplace dependent on user demand',
          rating: 'MEDIUM',
          ratingColor: Colors.amber,
          progress: 0.50,
          icon: Icons.trending_up,
          onTap: () => _showTooltip(
            context,
            'Market Liquidity',
            'Real estate is inherently illiquid. Your ability to sell depends on the P2P marketplace and other app users.\n\n**Average Time to Sell:** 45 days\n\n**Exit Options:**\n• List on in-app P2P marketplace\n• Wait for property liquidation event\n• Transfer to another investor (with fees)',
          ),
        ),
        const SizedBox(height: 16),

        // 2. Legal & Title (NEW)
        _buildGlassMorphismRiskCard(
          title: 'Legal & Title',
          subtitle: 'Azerbaijan property title verified',
          rating: 'VERIFIED',
          ratingColor: AppColors.primary,
          progress: 1.0,
          icon: Icons.verified,
          onTap: () => _showLegalTitleTooltip(context),
          actionLabel: 'View Registry',
          onAction: () {
            HapticUtils.lightImpact();
            UrlLauncherUtils.launchAzerbaijanRegistry('AZ-OH-2024-001');
          },
        ),
        const SizedBox(height: 16),

        // 3. Regulatory Risk (NEW)
        _buildGlassMorphismRiskCard(
          title: 'Regulatory Risk',
          subtitle: '2026 Clarity Act compliant',
          rating: 'MODERATE',
          ratingColor: Colors.orange,
          progress: 0.60,
          icon: Icons.gavel,
          onTap: () => _showRegulatoryTooltip(context),
          actionLabel: 'Compliance Report',
        ),
        const SizedBox(height: 16),

        // 4. Technical Security (NEW)
        _buildGlassMorphismRiskCard(
          title: 'Technical Security',
          subtitle: 'Smart contract audited by CertiK',
          rating: '98/100',
          ratingColor: AppColors.primary,
          progress: 0.98,
          icon: Icons.security,
          badge: 'AUDITED',
          onTap: () => _showTechnicalSecurityTooltip(context),
          actionLabel: 'View Audit',
        ),
        const SizedBox(height: 16),

        // 5. FX / Currency Risk (NEW - Dynamic)
        _buildGlassMorphismRiskCard(
          title: 'FX / Currency Risk',
          subtitle: 'USD token / AZN rental income',
          rating: _getFxRiskLevel(),
          ratingColor: _getFxRiskColor(),
          progress: _calculateFxRiskProgress(),
          icon: Icons.currency_exchange,
          liveData: '1 USD = ${_usdToAznRate.toStringAsFixed(2)} AZN',
          onTap: () => _showFxRiskTooltip(context),
        ),
      ],
    );
  }

  String _getFxRiskLevel() {
    if (_fxVolatility < 2.0) return 'LOW';
    if (_fxVolatility > 4.0) return 'HIGH';
    return 'MODERATE';
  }

  Color _getFxRiskColor() {
    if (_fxVolatility < 2.0) return AppColors.primary;
    if (_fxVolatility > 4.0) return Colors.red;
    return Colors.orange;
  }

  double _calculateFxRiskProgress() {
    // Volatility 0-5% mapped to 0-100%
    return (_fxVolatility / 5.0).clamp(0.0, 1.0);
  }

  Widget _buildGlassMorphismRiskCard({
    required String title,
    required String subtitle,
    required String rating,
    required Color ratingColor,
    required double progress,
    required IconData icon,
    String? badge,
    String? liveData,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return GestureDetector(
      onTap: () {
        HapticUtils.mediumImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: ratingColor, size: 20),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ratingColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: ratingColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        rating,
                        style: TextStyle(
                          color: ratingColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                if (badge != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              badge,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                if (liveData != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        liveData,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(ratingColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LOW',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (actionLabel != null)
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          onAction?.call();
                        },
                        child: Row(
                          children: [
                            Text(
                              actionLabel,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.open_in_new,
                              color: AppColors.primary,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    const Text(
                      'HIGH',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  void _showTooltip(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Got It',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalTitleTooltip(BuildContext context) {
    _showTooltip(
      context,
      'Legal & Title Verification',
      '**Azerbaijan Property Law**\n\nForeigners can own buildings but NOT land in Azerbaijan. The land must be held under a 99-year lease from the state.\n\n**This Property:**\n✅ Building ownership: Verified\n✅ Land lease: 99-year term (expires 2123)\n✅ Title registered with State Service for Registration of Property\n\n**Protection:** Assets held in ring-fenced SPV (Delaware/Azerbaijan LLC), legally separated from Orre MMC corporate risks.',
    );
  }

  void _showRegulatoryTooltip(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gavel, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Text(
                      'Regulatory Compliance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Evolving Regulation - Stay Informed',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '2026 Clarity Act',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This token is classified as a Digital Security under the 2026 Clarity Act. Orre MMC is registered with the Azerbaijan Securities Commission as a digital asset issuer.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Rights:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  'Investor protection equivalent to traditional securities',
                ),
                _buildBulletPoint('Mandatory quarterly financial disclosures'),
                _buildBulletPoint(
                  'Right to vote on major asset decisions (if holding >5%)',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Restrictions:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Resale requires KYC/AML verification'),
                _buildBulletPoint(
                  'Subject to capital gains tax in your jurisdiction',
                ),
                _buildBulletPoint('May be restricted in certain countries'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Got It',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTechnicalSecurityTooltip(BuildContext context) {
    _showTooltip(
      context,
      'Technical Security',
      '**Smart Contract Audit**\n\n✅ Audited by: CertiK (2024)\n✅ Security Score: 98/100\n✅ Vulnerabilities: 0 Critical, 0 High\n\n**Base L2 Security:**\nInherited Ethereum Mainnet security via Base Network Layer 2. Your investments are protected by the same cryptographic security as Ethereum.\n\n**On-Chain Verification:**\nAll transactions are publicly verifiable on BaseScan. Full transparency guaranteed.',
    );
  }

  void _showFxRiskTooltip(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.currency_exchange, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Text(
                      'Currency Exposure',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Currency volatility may affect returns',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'USD Token / AZN Income Mismatch',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your tokens are priced in USD (\$1,250/share), but property rental income is collected in Azerbaijani Manat (AZN).',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFxDataRow(
                  'Current Exchange Rate',
                  '${_usdToAznRate.toStringAsFixed(2)} AZN = 1 USD',
                ),
                _buildFxDataRow(
                  '30-Day Volatility',
                  '±${_fxVolatility.toStringAsFixed(1)}%',
                ),
                const SizedBox(height: 16),
                const Text(
                  'What This Means:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  'If AZN weakens vs USD, dividend payments decrease in dollar terms',
                ),
                _buildBulletPoint('If AZN strengthens, dividends increase'),
                const SizedBox(height: 16),
                const Text(
                  'Our Hedge:',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Orre MMC maintains a 6-month AZN reserve to smooth short-term fluctuations. Long-term exposure remains.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Example Impact:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildExampleRow('Expected monthly rent', '2,550 AZN'),
                      _buildExampleRow(
                        'At ${_usdToAznRate.toStringAsFixed(2)} rate',
                        '\$${(2550 / _usdToAznRate).toStringAsFixed(0)} USD',
                      ),
                      _buildExampleRow(
                        'If rate moves to ${(_usdToAznRate + 0.15).toStringAsFixed(2)}',
                        '\$${(2550 / (_usdToAznRate + 0.15)).toStringAsFixed(0)} USD (-${(((2550 / (_usdToAznRate + 0.15)) / (2550 / _usdToAznRate) - 1) * -100).toStringAsFixed(1)}%)',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Got It',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFxDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMitigationStrategy() {
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.shield, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Mitigation Strategy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 1. Base L2 Security (NEW)
        _buildStrategyItem(
          Icons.link,
          'Base L2 Security',
          'Inherited Ethereum Mainnet security via Base Network',
          actionLabel: 'View on BaseScan',
          onAction: () {
            HapticUtils.lightImpact();
            UrlLauncherUtils.launchBaseScan(
              '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
            );
          },
        ),
        const SizedBox(height: 12),

        // 2. SPV Asset Isolation (Enhanced)
        _buildStrategyItem(
          Icons.gavel,
          'SPV Asset Isolation',
          'Property held in Delaware/Azerbaijan LLC, legally separated from Orre MMC corporate risks',
        ),
        const SizedBox(height: 12),

        // 3. Automated Tax & Fee Settlement (NEW)
        _buildStrategyItem(
          Icons.calculate,
          'Automated Tax Settlement',
          '10% Azerbaijan withholding + 20% performance fee auto-settled by smart contract before payout',
        ),
        const SizedBox(height: 12),

        // 4. State Registry Link (NEW)
        _buildStrategyItem(
          Icons.account_balance,
          'Property Registry Link',
          'Verified on Azerbaijan State Service for Registration of Property',
          actionLabel: 'View Registry',
          onAction: () {
            HapticUtils.lightImpact();
            UrlLauncherUtils.launchAzerbaijanRegistry('AZ-OH-2024-001');
          },
        ),
        const SizedBox(height: 12),

        // 5. Insurance (Existing)
        _buildStrategyItem(
          Icons.policy,
          'Comprehensive Insurance',
          'Full coverage against structural defects and natural disasters',
        ),
        const SizedBox(height: 12),

        // 6. Custody (Existing)
        _buildStrategyItem(
          Icons.verified_user,
          'Third-Party Custody',
          'Institutional custodians manage financial flows',
        ),
      ],
    );
  }

  Widget _buildStrategyItem(
    IconData icon,
    String title,
    String desc, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onAction,
                    child: Row(
                      children: [
                        Text(
                          actionLabel,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STARTING FROM',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '\$1,250',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      ' / share',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.heavyImpact(); // Heavy feedback for investment action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'INVEST NOW',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // Background arc
    final paintBg = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paintBg,
    );

    // Active arc (Moderate)
    final paintActive = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * 0.55,
      false,
      paintActive,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
