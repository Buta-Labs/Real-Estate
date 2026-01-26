import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class MilestoneRewardsScreen extends StatelessWidget {
  const MilestoneRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Milestone Rewards'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withOpacity(0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildCurrentStatusCard(),
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Icon(Icons.military_tech, color: Color(0xFFF4D125)),
                    SizedBox(width: 8),
                    Text(
                      'The Luxury Path',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMilestoneCard(
                  title: 'Silver Tier',
                  reward: '\$1,000 Cash Bonus',
                  description:
                      'You\'ve earned a \$1,000 cash bonus for successfully growing the Orre network. Funds are available in your wallet.',
                  status: 'UNLOCKED',
                  statusColor: Colors.green,
                  image:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuClIAnsxmaAdEP8PRBQXAcm97Sk3n2QKeOyioc1Y7N4cMK4uBdKWH-V2iPjPszaUl7vbQbvug46PngNnYNw0Vc3MaIGXUgcmwQOlJUwAiJVep-tXL20stffEdLJ4arBW_QRw6qQYpbiVcRwUKdFiUTvfom1IMckG9Roni5zKuosuAzZQQWMn7kO744TlwtXMozDQeAaqFcOelL3dAd0GhmOe4ymhGwSGr7jsVQAUj8xVvAovq8NklZDaGvuy6wk9iymqzTp-Ta_3A',
                  buttonText: 'Claimed',
                  isClaimed: true,
                ),
                const SizedBox(height: 16),
                _buildMilestoneCard(
                  title: 'Gold Tier',
                  reward: '3-Night Villa Stay',
                  description:
                      'Unlock a luxury escape to a premium Orre managed villa in Bali or Marbella. All-inclusive luxury for you and a guest.',
                  status: 'IN PROGRESS',
                  statusColor: const Color(0xFFF4D125),
                  image:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBSOv-HYXUNStDkhnHQkOPOLFDfiYiXPvgwq4z135Of65eWIiutF5nlLjz0hRq-mTOdVtarHOJsz5xIXkG04tMCKpSGqeYlUPOqUgEh0ZIJqY9hxW_gMchG62Q9xkwO2zIZcUN8nh9TBEeqjV4RITJtKOFy8Gd9ap8EcSq0R3Ves2HbzvOZRrffqRY-61gvNQ_etrBJC3LVCOLP4WnuLggOl6dRXV6CwFmvBuyvngbsOi5okv9QWQoRiRpfQcXnSGRuVzEKZx3dyA',
                  buttonText: 'View Details',
                  progress: '7 Referrals Remaining',
                ),
              ],
            ),
          ),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF28261E).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4D125).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT RANK',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Silver Achiever',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4D125).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF4D125).withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  '18 Referrals',
                  style: TextStyle(
                    color: Color(0xFFF4D125),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress to Gold Tier',
                style: TextStyle(color: Colors.white70),
              ),
              const Text(
                '72%',
                style: TextStyle(
                  color: Color(0xFFF4D125),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.72,
              backgroundColor: const Color(0xFFF4D125).withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF4D125),
              ),
              minHeight: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '7 more successful referrals needed',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard({
    required String title,
    required String reward,
    required String description,
    required String status,
    required Color statusColor,
    required String image,
    required String buttonText,
    bool isClaimed = false,
    String? progress,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(image, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                      // Backdrop blur would go here
                    ),
                    child: Row(
                      children: [
                        if (status == 'UNLOCKED')
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: statusColor,
                          ),
                        if (status == 'UNLOCKED') const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
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
          Padding(
            padding: const EdgeInsets.all(20),
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
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          reward,
                          style: const TextStyle(
                            color: Color(0xFFF4D125),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payments,
                        color: Color(0xFFF4D125),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white60, height: 1.5),
                ),
                const SizedBox(height: 16),
                if (progress != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REMAINING',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '7 Referrals',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isClaimed
                          ? const Color(0xFFF4D125)
                          : Colors.white.withOpacity(0.1),
                      foregroundColor: isClaimed ? Colors.black : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundDark.withOpacity(0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR REFERRAL LINK',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'orre.invest/join/user-2941',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4D125),
                  foregroundColor: Colors.black,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
