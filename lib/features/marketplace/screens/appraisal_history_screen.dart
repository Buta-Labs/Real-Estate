import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class AppraisalHistoryScreen extends StatelessWidget {
  const AppraisalHistoryScreen({super.key});

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
            title: Column(
              children: [
                Text(
                  'The Grandview Estate',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Appraisal History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildAnalyticalChart(),
                  const SizedBox(height: 24),
                  _buildTimeframeSelector(),
                  const SizedBox(height: 24),
                  _buildMilestoneTable(),
                  const SizedBox(height: 32),
                  _buildDownloadCTA(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1c1c1a),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Valuation'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '\$14,850,000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+2.1% (Last 6m)',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1c1c1a),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asset Appreciation'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '+24.5%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Since Acquisition',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticalChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1c1a),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Value Tracking',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Historical Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartLegend('Certified', AppColors.primary),
                  const SizedBox(height: 4),
                  _buildChartLegend('Market Avg', Colors.white38, isLine: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(painter: _ChartPainter()),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                ['JAN \'22', 'JUL \'22', 'JAN \'23', 'JUL \'23', 'JAN \'24']
                    .map(
                      (e) => Text(
                        e,
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color, {bool isLine = false}) {
    return Row(
      children: [
        isLine
            ? Container(width: 12, height: 2, color: color)
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTimeButton('1Y', false),
          _buildTimeButton('3Y', false),
          _buildTimeButton('5Y', true),
          _buildTimeButton('MAX', false),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String label, bool isActive) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.backgroundDark : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appraisal Milestones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildTableRow('Date & Firm', 'Value', 'Change', isHeader: true),
              const Divider(height: 1, color: Colors.white10),
              _buildTableRow(
                'Oct 12, 2023',
                '\$14.85M',
                '+4.2%',
                subtitle: 'Knight Frank LLP',
                isPositive: true,
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildTableRow(
                'Mar 05, 2023',
                '\$14.25M',
                '+6.8%',
                subtitle: 'Cushman & Wakefield',
                isPositive: true,
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildTableRow(
                'Jan 15, 2022',
                '\$13.06M',
                'Initial',
                subtitle: 'JLL Valuation',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(
    String col1,
    String col2,
    String col3, {
    String? subtitle,
    bool isHeader = false,
    bool isPositive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  col1,
                  style: TextStyle(
                    color: isHeader ? Colors.white38 : Colors.white,
                    fontWeight: isHeader ? FontWeight.normal : FontWeight.bold,
                    fontSize: isHeader ? 12 : 14,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              col2,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isHeader ? Colors.white38 : Colors.white,
                fontWeight: isHeader ? FontWeight.normal : FontWeight.w900,
                fontSize: isHeader ? 12 : 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: isHeader
                  ? Text(
                      col3,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        col3,
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCTA() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.description),
          label: const Text('DOWNLOAD FULL AUDIT REPORT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDark,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'LAST UPDATED OCT 14, 2023 • ALL VALUES IN USD',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw Dashed Line (Market Avg)
    final paintDash = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Simple Path for Dash
    final pathDash = Path();
    pathDash.moveTo(0, size.height * 0.9);
    pathDash.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.8,
      size.width,
      size.height * 0.6,
    );
    canvas.drawPath(pathDash, paintDash);

    // Draw Performance Line
    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathLine = Path();
    pathLine.moveTo(0, size.height);
    pathLine.lineTo(size.width * 0.2, size.height * 0.8);
    pathLine.lineTo(size.width * 0.4, size.height * 0.6);
    pathLine.lineTo(size.width * 0.6, size.height * 0.5);
    pathLine.lineTo(size.width * 0.8, size.height * 0.3);
    pathLine.lineTo(size.width, size.height * 0.2);

    canvas.drawPath(pathLine, paintLine);

    // Draw Dots
    final paintDot = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.6), 4, paintDot);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 4, paintDot);

    // Draw Halo Dot at end
    final paintHalo = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(Offset(size.width, size.height * 0.2), 5, paintDot);
    canvas.drawCircle(Offset(size.width, size.height * 0.2), 5, paintHalo);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
