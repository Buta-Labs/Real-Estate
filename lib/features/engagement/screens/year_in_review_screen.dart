import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class YearInReviewScreen extends StatelessWidget {
  const YearInReviewScreen({super.key});

  final Color _gold = const Color(0xFFF4C025);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121008),
      body: Stack(
        children: [
          // Background Elements
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [Color(0xFF231e10), Color(0xFF121008)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildProgressIndicators(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildMainCard(),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),

          Positioned(
            top: 48,
            right: 24,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index == 2 ? _gold : _gold.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'PERFORMANCE SUMMARY',
          style: TextStyle(
            color: _gold,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
            children: [
              const TextSpan(text: 'Your 2023 \n'),
              TextSpan(
                text: 'at Orre LLC',
                style: TextStyle(
                  color: _gold,
                  shadows: [
                    Shadow(color: _gold.withValues(alpha: 0.4), blurRadius: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.05),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL INCOME EARNED',
            style: TextStyle(
              color: _gold.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$42,850.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: _gold.withValues(alpha: 0.4), blurRadius: 15),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0BDA1D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Color(0xFF0BDA1D), size: 16),
                SizedBox(width: 4),
                Text(
                  '+24.5% vs 2022',
                  style: TextStyle(
                    color: Color(0xFF0BDA1D),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(height: 1, width: 60, color: _gold.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('PORTFOLIO SIZE', '12', 'Properties'),
              ),
              Expanded(child: _buildStatItem('NEW ADDITIONS', '+5', 'Assets')),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'TOP PERFORMING ASSET',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_city, color: _gold, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'The Zenith Plaza, NYC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String sub) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          sub,
          style: TextStyle(
            color: _gold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: const Color(0xFF121008),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: _gold.withValues(alpha: 0.4),
              elevation: 8,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ios_share, size: 20),
                SizedBox(width: 8),
                Text(
                  'SHARE MY SUCCESS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Data reflects performance from Jan 1, 2023 - Dec 31, 2023. Real estate investments involve risk.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
