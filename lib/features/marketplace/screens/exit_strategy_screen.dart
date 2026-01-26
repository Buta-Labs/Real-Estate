import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class ExitStrategyScreen extends StatelessWidget {
  const ExitStrategyScreen({super.key});

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
            title: const Text(
              'Exit Strategy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(),
                  const SizedBox(height: 32),
                  const Text(
                    'AVAILABLE ROUTES',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    'Instant',
                    'currency_exchange',
                    'Secondary Market (P2P)',
                    'List your tokens on our internal marketplace to sell directly to other investors. Provides immediate liquidity based on current market demand.',
                    'Processing: ~24-48h',
                    'View Marketplace',
                    AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    'Term-based',
                    'real_estate_agent',
                    'Final Asset Sale',
                    'At the end of the term (5-7 years), the physical property is sold. Tokens are redeemed for the final sale value plus all accrued appreciation.',
                    'Est. Returns: 12-15% APY',
                    'Investment Details',
                    Colors.blue[400]!,
                  ),
                  const SizedBox(height: 48),
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Lifecycle Timeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTimeline(),
                  const SizedBox(height: 48),
                  _buildFooterCard(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your path to liquidity',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Orre MMC provides flexible exit paths tailored to your investment goals. Choose between immediate cash-out or long-term appreciation.',
          style: TextStyle(
            color: Colors.green[100]!.withOpacity(0.7),
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    String badge,
    String iconName,
    String title,
    String desc,
    String footerLeft,
    String footerRight,
    Color color,
  ) {
    IconData icon;
    switch (iconName) {
      case 'currency_exchange':
        icon = Icons.currency_exchange;
        break;
      case 'real_estate_agent':
        icon = Icons.real_estate_agent;
        break;
      default:
        icon = Icons.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              height: 1.4,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  footerLeft,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Row(
                  children: [
                    Text(
                      footerRight,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 12, color: color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _buildTimelineStep(
          Icons.token,
          'Token Acquisition',
          'Day 1: Purchase fractional ownership',
          isLast: false,
        ),
        _buildTimelineStep(
          Icons.payments,
          'Rental Yields',
          'Ongoing: Monthly dividend distribution',
          isLast: false,
        ),
        _buildTimelineStep(
          Icons.swap_horiz,
          'Secondary Liquidity',
          'Anytime: List tokens for peer-to-peer sale',
          isLast: false,
        ),
        _buildTimelineStep(
          Icons.sell,
          'Final Redemption',
          'Maturity: Asset sale & profit realization',
          isLast: true,
          isOutline: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep(
    IconData icon,
    String title,
    String subtitle, {
    required bool isLast,
    bool isOutline = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isOutline
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: isOutline
                      ? Border.all(color: AppColors.primary.withOpacity(0.5))
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isOutline
                      ? AppColors.primary
                      : AppColors.backgroundDark,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.primary.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.gavel, color: Colors.grey),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offering Memorandum',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Legal terms and risk factors',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const Row(
                children: [
                  Text(
                    'Learn More',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.open_in_new, color: AppColors.primary, size: 14),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Real estate investments carry risk. Past performance does not guarantee future results.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
