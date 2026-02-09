import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/core/utils/haptic_utils.dart';
import 'package:orre_mmc_app/core/utils/url_launcher_utils.dart';
import 'package:orre_mmc_app/core/services/currency_service.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';
import 'dart:math' as math;
import 'dart:ui';

class RiskAssessmentScreen extends StatefulWidget {
  final Property property;
  const RiskAssessmentScreen({super.key, required this.property});

  @override
  State<RiskAssessmentScreen> createState() => _RiskAssessmentScreenState();
}

class _RiskAssessmentScreenState extends State<RiskAssessmentScreen> {
  // No longer used: double _usdToAznRate = 1.70;
  double _fxVolatility = 2.3;

  @override
  void initState() {
    super.initState();
    _loadCurrencyData();
  }

  Future<void> _loadCurrencyData() async {
    // We only need volatility now as the peg is fixed at 1.70
    final volatility = await CurrencyService.getVolatility();
    setState(() {
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
            title: Column(
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
                  widget.property.title,
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
          'Balanced asset profile prioritizing capital preservation and long-term appreciation. Optimized for investors with a 3-5 year holding horizon.',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Real estate is inherently illiquid. Your ability to sell depends on the P2P marketplace and other app users.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Liquidity: Market Dependent (Varies by Demand)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Exit Options:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  'Trade on Orre P2P Marketplace (Instant Listing)',
                ),
                _buildBulletPoint(
                  'Private Transfer (Peer-to-Peer Wallet Send)',
                ),
                _buildBulletPoint('Property Sale Event (5-7 Year Exit)'),
                const SizedBox(height: 16),
                const Text(
                  'No Guarantee',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Note: Tokens are not redeemable by the issuer on demand. You must find a buyer on the marketplace.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
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
          subtitle: 'Operating under Civil Law',
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
          subtitle: 'Verified OpenZeppelin standards',
          rating: 'SECURE',
          ratingColor: AppColors.primary,
          progress: 1.0,
          icon: Icons.security,
          onTap: () => _showTechnicalSecurityTooltip(context),
          actionLabel: 'View on BaseScan',
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
          liveData: '1.70 AZN = 1 USD (Fixed Peg)',
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
                    Expanded(
                      child: Row(
                        children: [
                          Icon(icon, color: ratingColor, size: 20),
                          const SizedBox(width: 12),
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
                                  subtitle,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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

  void _showTooltip(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: content,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Got It',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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

  void _showLegalTitleTooltip(BuildContext context) {
    _showTooltip(
      context,
      'Legal & Title Verification',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Asset Ownership Model',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'To ensure operational efficiency and lower costs for investors, all real estate assets are currently acquired and titled directly under Orre MMC.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'This Property',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '✅ Title Holder: Orre MMC (The Issuer).',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const Text(
            '✅ Investor Rights: Tokens represent a contractual right to the specific revenue and sale proceeds of this specific unit.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const Text(
            '✅ Segregation: Rent and sale funds are strictly segregated via Smart Contract and internal accounting ledgers.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Text(
            'Risk Disclosure',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Assets are held centrally. While Orre MMC maintains comprehensive liability insurance, a legal claim against the Issuer could theoretically impact the broader portfolio.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showRegulatoryTooltip(BuildContext context) {
    _showTooltip(
      context,
      'Regulatory Compliance',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.gavel, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Operating under Civil Law',
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
          const SizedBox(height: 20),
          const Text(
            '1. Legal Framework',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'These tokens function as digital proofs of a contractual agreement under the Civil Code of the Republic of Azerbaijan. Orre MMC enforces strict KYC/AML standards aligned with Central Bank guidelines.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '2. Your Rights',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(
            'Economic Interest: You have a direct right to share in rental income and sale proceeds.',
          ),
          _buildBulletPoint(
            'Transparency: You have access to monthly performance reports and bank-verified proof of funds.',
          ),
          _buildBulletPoint(
            'Asset Security: The underlying real estate is fully insured and legally titled.',
          ),
          const SizedBox(height: 16),
          const Text(
            '3. Restrictions',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(
            'Identity Verification: Mandatory KYC/AML checks are required before any withdrawal.',
          ),
          _buildBulletPoint(
            'Tax Responsibility: Investors are responsible for declaring capital gains in their local jurisdiction.',
          ),
          _buildBulletPoint(
            'Transferability: Tokens may only be sold on the Orre P2P Market to verified users.',
          ),
        ],
      ),
    );
  }

  void _showTechnicalSecurityTooltip(BuildContext context) {
    _showTooltip(
      context,
      'Technical Security',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Smart Contract Standards',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.code, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Built on audited OpenZeppelin libraries. Source code is verified on BaseScan for full transparency.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Network Security',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Secured by Base L2 (Coinbase), inheriting Ethereum\'s cryptographic security.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Verification',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.verified_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All transactions and token holdings are publicly verifiable on-chain.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFxRiskTooltip(BuildContext context) {
    _showTooltip(
      context,
      'Currency Exposure',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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
                    '⚠️ Devaluation Risk (Pegged Currency)',
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
          const SizedBox(height: 20),
          const Text(
            '1. USD Token / AZN Income Mismatch',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your tokens are priced in USD (\$50/share), but property rental income is collected in Azerbaijani Manat (AZN).',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          _buildFxDataRow(
            'Current Exchange Rate',
            '1.70 AZN = 1 USD (Fixed Peg)',
          ),
          _buildFxDataRow('Market Status', 'Stable (Pegged by Central Bank)'),
          const SizedBox(height: 16),
          const Text(
            '2. What This Means',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(
            'Stability: Returns are stable as long as the Central Bank maintains the 1.70 peg.',
          ),
          _buildBulletPoint(
            'Risk: If the government devalues the currency (e.g., to 2.00 AZN), the USD value of your monthly dividends will decrease proportionally.',
          ),
          const SizedBox(height: 16),
          const Text(
            '3. Our Strategy (Immediate Conversion)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Orre MMC converts collected AZN rent into USDC/USD within 48 hours of receipt to minimize exposure to any sudden devaluation events.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '4. Example Impact (Devaluation Scenario)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildExampleRow('Expected Monthly Rent', '2,550 AZN'),
                _buildExampleRow('At Current Rate (1.70)', '\$1,500 USD'),
                _buildExampleRow(
                  'If Rate Moves to 1.85',
                  '\$1,378 USD (-8.1%)',
                ),
              ],
            ),
          ),
        ],
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

        // 2. Direct Asset Ownership
        _buildStrategyItem(
          Icons.gavel,
          'Direct Asset Ownership',
          'Property titled directly under Orre MMC with strictly segregated revenue funds',
        ),
        const SizedBox(height: 12),

        // 3. Automated Net Distribution
        _buildStrategyItem(
          Icons.calculate,
          'Automated Net Distribution',
          'Dividends are distributed net of 10% Azerbaijan withholding tax and performance fees to ensure full compliance.',
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

        // 6. Secure Treasury Management
        _buildStrategyItem(
          Icons.verified_user,
          'Secure Treasury Management',
          'Assets and funds are secured using Multi-Signature wallets and strict operational access controls.',
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
                      '\$50',
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
