import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';

class DiversificationScreen extends StatelessWidget {
  const DiversificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Analytics',
        ), // React header says 'Analytics' but file is Diversification
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(
              Icons.insights,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildScoreChart(),
            const SizedBox(height: 32),
            _buildBreakdownSection(),
            const SizedBox(height: 32),
            _buildAIInsightCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Optimize Portfolio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              SizedBox(width: 8),
              Icon(Icons.bolt, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChart() {
    return Center(
      child: SizedBox(
        width: 256,
        height: 256,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Track
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 12,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            // Progress
            const SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: 0.82,
                strokeWidth: 12,
                color: Color(0xFF13EC80),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DIVERSIFICATION',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '82',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: '/100',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '+5.2%',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SCORE BREAKDOWN',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const Text(
              'Details',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBreakdownCard(
          icon: Icons.pie_chart,
          iconColor: AppColors.primary,
          title: 'Asset Type',
          subtitle: 'Rental vs. Growth',
          status: 'Optimal',
          statusColor: AppColors.primary,
          primaryColor: AppColors.primary,
          secondaryColor: Colors.white.withOpacity(0.2),
          primaryLabel: 'Rental (65%)',
          secondaryLabel: 'Growth (35%)',
          percent: 0.65,
        ),
        const SizedBox(height: 16),
        _buildBreakdownCard(
          icon: Icons.public,
          iconColor: Colors.blue[400]!,
          title: 'Geography',
          subtitle: 'Baku vs. Coastal',
          status: 'Review',
          statusColor: Colors.amber[400]!,
          primaryColor: Colors.blue[400]!,
          secondaryColor: Colors.amber[400]!,
          primaryLabel: 'Baku (82%)',
          secondaryLabel: 'Coastal (18%)',
          percent: 0.82,
        ),
      ],
    );
  }

  Widget _buildBreakdownCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required Color primaryColor,
    required Color secondaryColor,
    required String primaryLabel,
    required String secondaryLabel,
    required double percent,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      color: Colors.white.withOpacity(0.05),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (percent * 100).toInt(),
                    child: Container(color: primaryColor),
                  ),
                  Expanded(
                    flex: ((1 - percent) * 100).toInt(),
                    child: Container(color: secondaryColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(primaryLabel, primaryColor),
              _buildLegendItem(secondaryLabel, secondaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.amber[800]!.withOpacity(0.1),
            const Color(0xFF102219),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.amber[800]!.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber[400], size: 20),
              const SizedBox(width: 8),
              Text(
                'THE REACTOR AI',
                style: TextStyle(
                  color: Colors.amber[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
                fontSize: 14,
              ),
              children: [
                const TextSpan(
                  text:
                      'Your portfolio is heavily concentrated in Baku. Increasing your ',
                ),
                TextSpan(
                  text: 'Coastal exposure by 12%',
                  style: TextStyle(
                    color: Colors.amber[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: ' will reach the \'Elite\' diversification tier.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
