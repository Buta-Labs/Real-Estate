import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';

class LevelUpScreen extends StatelessWidget {
  const LevelUpScreen({super.key});

  final Color _gold = const Color(0xFFF2D00D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C14),
      body: Stack(
        children: [
          // Background Effects
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [Color(0xFF1a1c24), Color(0xFF0A0C14)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        _buildHeadline(),
                        const SizedBox(height: 32),
                        _buildBadge(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildPerkCard(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.6)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'NEW STATUS UNLOCKED',
                  style: TextStyle(
                    color: _gold.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildHeadline() {
    return Column(
      children: [
        Text(
          'You\'ve Leveled Up!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: _gold.withValues(alpha: 0.4), blurRadius: 20),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'WHALE RANK',
          style: TextStyle(
            color: _gold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return SizedBox(
      height: 280,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.2),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD32bEKn4dswMzlO0Z2m86pBFCkhUdASXvP4DDTAx2C96DlMQKd-F-46guk5DRGrwMJqni-qXZJoHVC2QANCIiGxoqdSkZ8i0K3D0dBtQYK7yBFkW_NEOlQbu3W_e0SXwugZc_Bv1_FvZ66_IZ1K3ibiUpyzCSzO4uEepPYuP7q0hmmeyH7EFE6IzHTsWHqG8UrbP1gjPi7sfybJjWiY0RKAFrOZYNxDHnzIoEuzl9hAeINozlf0fKiXTmFxzo9B9PZ2e-zNRq5ZA',
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildPerkCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(16),
      color: Colors.white.withValues(alpha: 0.05),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.military_tech, color: _gold),
              ),
              const SizedBox(width: 12),
              const Text(
                'New Whale Perks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPerkItem(
            Icons.support_agent,
            'Priority Support',
            '24/7 dedicated account manager access.',
          ),
          const SizedBox(height: 16),
          _buildPerkItem(
            Icons.insights,
            'Exclusive Market Insights',
            'Early access to quarterly property reports.',
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _gold.withValues(alpha: 0.8), size: 24),
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
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: const Color(0xFF0A0C14),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              shadowColor: _gold.withValues(alpha: 0.4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text(
                  'SHARE YOUR ACHIEVEMENT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Continue to Dashboard',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
