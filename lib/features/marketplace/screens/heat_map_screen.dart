import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';

class HeatMapScreen extends StatelessWidget {
  const HeatMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Market Heat Map'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildControls(),
            _buildMetrics(),
            _buildHeatGrid(context),
            _buildTrendingList(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Volume',
                  style: TextStyle(
                    color: AppColors.backgroundDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                child: const Text(
                  'Price Volatility',
                  style: TextStyle(
                    color: AppColors.primary,
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

  Widget _buildMetrics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL ACTIVITY',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'High Liquidity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+14.2%',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'LAST 24 HOURS',
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
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [Color(0xFF13EC5B), Color(0xFFFFD700)],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOW VOLUME',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'PEAK TRADING',
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

  Widget _buildHeatGrid(BuildContext context) {
    return SizedBox(
      height: 250,
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHeatTile(
            'Resi',
            '94%',
            AppColors.primary,
            AppColors.backgroundDark,
          ),
          _buildHeatTile(
            'Comm',
            '82%',
            AppColors.primary.withOpacity(0.8),
            AppColors.backgroundDark,
          ),
          _buildHeatTile(
            'Ind',
            '71%',
            const Color(0xFFFFD700).withOpacity(0.9),
            AppColors.backgroundDark,
          ),
          _buildHeatTile(
            'Retail',
            '42%',
            AppColors.primary.withOpacity(0.4),
            AppColors.primary,
            border: AppColors.primary.withOpacity(0.2),
          ),

          _buildHeatTile(
            'NYC',
            '88%',
            const Color(0xFFFFD700),
            AppColors.backgroundDark,
          ),
          _buildHeatTile(
            'LDN',
            '98%',
            AppColors.primary,
            AppColors.backgroundDark,
            border: Colors.white.withOpacity(0.4),
          ),
          _buildHeatTile(
            'DXB',
            '15%',
            AppColors.primary.withOpacity(0.2),
            AppColors.primary,
            border: AppColors.primary.withOpacity(0.1),
          ),
          _buildHeatTile(
            'SNG',
            '56%',
            const Color(0xFFFFD700).withOpacity(0.6),
            AppColors.backgroundDark,
          ),

          _buildHeatTile(
            'Mxd',
            '65%',
            AppColors.primary.withOpacity(0.6),
            AppColors.backgroundDark,
          ),
          _buildHeatTile(
            'Emerging Markets',
            '48%',
            const Color(0xFFFFD700).withOpacity(0.4),
            AppColors.backgroundDark,
            isWide: true,
          ),
          _buildHeatTile(
            'High',
            '91%',
            AppColors.primary,
            AppColors.backgroundDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHeatTile(
    String label,
    String value,
    Color color,
    Color textColor, {
    Color? border,
    bool isWide = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: border != null ? Border.all(color: border, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: isWide ? 8 : 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Trending Properties',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTrendItem(
            'Elysian Heights Phase II',
            'Residential • London, UK',
            '\$452.20',
            '+4.2%',
          ),
          const SizedBox(height: 8),
          _buildTrendItem(
            'Nexus Tech Plaza',
            'Commercial • San Francisco',
            '\$1,280.00',
            '+0.8%',
            isGold: true,
          ),
          const SizedBox(height: 8),
          _buildTrendItem(
            'The Sapphire Penthouse',
            'Mixed-Use • Dubai, UAE',
            '\$892.50',
            '+12.5%',
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    String name,
    String sub,
    String price,
    String change, {
    bool isGold = false,
  }) {
    final color = isGold ? const Color(0xFFFFD700) : AppColors.primary;
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white.withOpacity(0.05),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    change,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
