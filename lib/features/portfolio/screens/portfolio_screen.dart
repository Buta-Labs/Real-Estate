import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/features/portfolio/providers/portfolio_provider.dart';
import 'package:orre_mmc_app/features/portfolio/models/portfolio_item.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_result.dart';
import 'package:orre_mmc_app/features/marketplace/domain/stay_logic.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioAssetsProvider);
    final priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final incomeFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Background Glow
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.srcOver,
                  ),
                  child: Container(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 0.8,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                backgroundColor: AppColors.backgroundDark.withValues(
                  alpha: 0.8,
                ),
                floating: true,
                pinned: true,
                title: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: const NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCwy2JX6OrFcxekGJy_g_goo_pOR9Bht2NrVEZ1fSTDTt-phPuXWtcgbL0eT5IH1gTdBK0xaJrsqII1c6AGpI3DXKo_o30hAcqY-kXQUCBdmP4bxT3kH6vX4eqgvwl3MW9NNxsIwzaABLnC1XTotxfsQ0XB9VF8KCBQrAI42DiWKidUS_J5IU20uIgSUJPHfodyBlTuGVS7Zlxf05JMEqHLbMJJE3umpUFe5R96MXCFFdZwVrbTZbdeJHJmiwDKjLTNdqLv2ebljA',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          'Alexander Orre',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Portfolio Header Card
                    _buildPortfolioHeader(
                      portfolioAsync,
                      priceFormat,
                      incomeFormat,
                    ),

                    const SizedBox(height: 16),

                    // Claimable Earnings Section
                    _buildClaimableEarnings(portfolioAsync, ref, incomeFormat),

                    const SizedBox(height: 16),

                    const SizedBox(height: 16),

                    // Diversification Score (Static for now)
                    _buildDiversificationScore(),

                    const SizedBox(height: 24),

                    // Income History Chart Placeholder
                    _buildIncomeHistory(),

                    const SizedBox(height: 24),

                    // Your Assets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Assets',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.filter_list, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Asset List
                    ..._buildAssetList(portfolioAsync, priceFormat),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioHeader(
    AsyncValue<List<PortfolioItem>> portfolioAsync,
    NumberFormat priceFormat,
    NumberFormat incomeFormat,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      color: Colors.white.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Portfolio Value',
            style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          portfolioAsync.when(
            data: (items) {
              final totalValue = items.fold(
                0.0,
                (sum, item) => sum + item.currentValue,
              );
              return Text(
                priceFormat.format(totalValue),
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
            loading: () =>
                const Text('Loading...', style: TextStyle(fontSize: 24)),
            error: (err, stack) =>
                const Text('Error', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YTD YIELD',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '+8.4%',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MONTHLY INCOME',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incomeFormat.format(1550),
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildDiversificationScore() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 4,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                Text(
                  '82',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diversification Score',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Excellent • Low Risk',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildIncomeHistory() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Income History',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'View Report',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentBlue.withValues(alpha: 0.2),
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: CustomPaint(painter: ChartPainter()),
        ),
        const SizedBox(height: 8),
        // Month labels
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jan', style: TextStyle(color: Colors.grey, fontSize: 10)),
            Text('Feb', style: TextStyle(color: Colors.grey, fontSize: 10)),
            Text('Mar', style: TextStyle(color: Colors.grey, fontSize: 10)),
            Text('Apr', style: TextStyle(color: Colors.grey, fontSize: 10)),
            Text('May', style: TextStyle(color: Colors.grey, fontSize: 10)),
            Text('Jun', style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildAssetList(
    AsyncValue<List<PortfolioItem>> portfolioAsync,
    NumberFormat priceFormat,
  ) {
    return portfolioAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return [
            Center(
              child: Text(
                'No assets yet. Visit Marketplace!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ];
        }
        return items.map((item) => _buildAssetCard(item, priceFormat)).toList();
      },
      loading: () => [const Center(child: CircularProgressIndicator())],
      error: (e, stack) => [
        Text('Error: $e', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildAssetCard(PortfolioItem item, NumberFormat priceFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(item.property.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.property.title,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      item.property.location,
                      style: GoogleFonts.manrope(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VALUE',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              priceFormat.format(item.currentValue),
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TOKENS',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              item.balance.toStringAsFixed(2),
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.property.tierIndex == 2) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STAY BENEFIT',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      item.currentValue >= 5000
                          ? 'Unlocked: ${calculateStayRights(item.currentValue, item.property.price)} Days/Year'
                          : 'Invest \$${(5000 - item.currentValue).toStringAsFixed(0)} more to unlock stay',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: item.currentValue >= 5000
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: item.currentValue >= 5000
                      ? () {
                          // TODO: Implement Booking flow
                        }
                      : null,
                  icon: const Icon(Icons.hotel, size: 16),
                  label: const Text('Book Stay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.05,
                    ),
                    disabledForegroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClaimableEarnings(
    AsyncValue<List<PortfolioItem>> portfolioAsync,
    WidgetRef ref,
    NumberFormat incomeFormat,
  ) {
    return portfolioAsync.when(
      data: (items) {
        final totalClaimable = items.fold(
          0.0,
          (sum, item) => sum + item.claimableRent,
        );

        // If nothing to claim, don't show the section
        if (totalClaimable <= 0) return const SizedBox.shrink();

        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.accentBlue.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.savings, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Claimable Earnings',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    incomeFormat.format(totalClaimable),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              ...items.where((i) => i.claimableRent > 0).map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.property.title,
                          style: GoogleFonts.manrope(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final repo = ref.read(blockchainRepositoryProvider);
                          ScaffoldMessenger.of(ref.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Initiating Claim... Check Wallet.',
                              ),
                            ),
                          );
                          final result = await repo.claimRent(
                            item.property.contractAddress,
                            onStatusChanged: (status) {
                              // Optional: Toast or logs
                              debugPrint(status);
                            },
                          );

                          if (ref.context.mounted) {
                            // check mounted
                            if (result is Success) {
                              ScaffoldMessenger.of(ref.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Claim Success! Refreshing...'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Refresh the provider to update UI
                              ref.invalidate(portfolioAssetsProvider);
                            } else {
                              ScaffoldMessenger.of(ref.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Claim Failed'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.download_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'Claim ${incomeFormat.format(item.claimableRent)}',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Simple line chart mock
    final paint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.8,
      size.width * 0.4,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
