import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'dart:math' as math;

class RiskAssessmentScreen extends StatelessWidget {
  const RiskAssessmentScreen({super.key});

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
        _buildRiskFactorCard(
          title: 'Market Liquidity',
          subtitle: 'Secondary market exit speed',
          rating: 'Medium',
          ratingColor: Colors.amber,
          progress: 0.65,
        ),
        const SizedBox(height: 16),
        _buildRiskFactorCard(
          title: 'Location Demand',
          subtitle: 'District occupancy & growth rate',
          rating: 'Excellent',
          ratingColor: AppColors.primary,
          progress: 0.92,
          isHighlight: true,
        ),
      ],
    );
  }

  Widget _buildRiskFactorCard({
    required String title,
    required String subtitle,
    required String rating,
    required Color ratingColor,
    required double progress,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isHighlight ? AppColors.primary : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rating.toUpperCase(),
                  style: TextStyle(
                    color: ratingColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(ratingColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOW',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
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
        _buildStrategyItem(
          Icons.gavel,
          'Legal SPV Structure',
          'Assets are held in a ring-fenced Special Purpose Vehicle (SPV), protecting investments.',
        ),
        const SizedBox(height: 12),
        _buildStrategyItem(
          Icons.policy,
          'Comprehensive Insurance',
          'Full coverage against structural defects and natural disasters.',
        ),
        const SizedBox(height: 12),
        _buildStrategyItem(
          Icons.verified_user,
          'Custodian Oversight',
          'Third-party institutional custodians manage financial flows.',
        ),
      ],
    );
  }

  Widget _buildStrategyItem(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
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
        color: AppColors.backgroundDark.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
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
            onPressed: () {},
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
      ..color = Colors.white.withOpacity(0.1)
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

    // Approximating the dash effect using a smaller arc for now
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start at 180 degrees
      math.pi * 0.55, // Sweep to ~4.2 value
      false,
      paintActive,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
