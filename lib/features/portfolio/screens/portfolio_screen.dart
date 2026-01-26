import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.srcOver,
                  ), // No-op, just for structure
                  child: Container(),
                ), // Blur handled by widget tree above usually, or use ImageFilter.
              ),
            ),
          ),
          // Blur using BackdropFilter on top of the circles requires careful placement or just use ImageFilter.blur in a Container decoration if possible, but Flutter standard BoxShadow spread is easier.
          // Simplified glow:
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
                    AppColors.primary.withOpacity(0.1),
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
                backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
                floating: true,
                pinned: true,
                title: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
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
                          backgroundColor: Colors.white.withOpacity(0.1),
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
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withOpacity(0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Portfolio Value',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$124,500.00',
                            style: GoogleFonts.manrope(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Divider(color: Colors.white.withOpacity(0.1)),
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
                                    '\$1,550.00',
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
                    ),

                    const SizedBox(height: 16),

                    // Diversification Score
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
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
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                    ),

                    const SizedBox(height: 24),

                    // Income History Chart Placeholder
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
                            AppColors.accentBlue.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        // Mimic the chart with simple lines or custom painter ideally
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: CustomPaint(
                        painter: ChartPainter(), // Simple placeholder painter
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Month labels
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jan',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        Text(
                          'Feb',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        Text(
                          'Mar',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        Text(
                          'Apr',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        Text(
                          'May',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        Text(
                          'Jun',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),

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
                    _buildAssetCard(
                      'The Skyline Penthouse',
                      '101 Seaport Blvd, Boston',
                      '\$5,200',
                      '+\$450.00',
                      '50',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCh2AoGrTwTwSuN6n1_VCkFCJL6D79YHcUlMOqpzqMpySEp81pquUre9mMLwCjZRkfg6IfDxPHULuYPeyHQqbPoM9Nf1CYTogrP8f7rn6P2mYjxkt5CaT0wmOUaID5s7dgSE06Zthu5CQQ_sNIhlrZSejwDhh4veuQ8LcFQpDgSnk1jwWqO7b9OLjLfCOyzve2PLrMEhxCW010n2Xtm2TrsOuMhrTGEed5G_qRv9fbhtuFpmJqeTa177opfqy2PKZ-KHNFoPXuUBQ',
                    ),
                    const SizedBox(height: 16),
                    _buildAssetCard(
                      'Coastal Villa #4',
                      '45 Ocean Dr, Miami',
                      '\$12,000',
                      '+\$1,100.00',
                      '120',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCdWFkv7ES8DBdy1wK87eJ7MlIsal8wjgv0OLErL-dnsBkanYzHzjE4CT-NOvSRoaB890fDoU4QnKNh-Y7WRRF_haitRZ2Nsz7qKJdMEGVLAa79HFTIEiEFpOv9JSgCX9UorfcifkEtbuS_dCBIatL553gQ5oE64cELBm5MEtC0K9Ov2yDOl-nTICQbAKhEi3Wua3GKyWgEMpRnUkSuAkv5mRrZ_Pw3EknwPNo5nCdhITpoF3BWn_nBof24NZ6PYm8gyedPhH1Wnw',
                    ),

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

  Widget _buildAssetCard(
    String title,
    String subtitle,
    String value,
    String rent,
    String tokens,
    String image,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                    image: NetworkImage(image),
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
                      title,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
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
                              value,
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
                              'RENT ACCRUED',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              rent,
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[300],
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.sell, size: 16),
                  label: const Text('Sell P2P'),
                ),
              ),
            ],
          ),
        ],
      ),
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
