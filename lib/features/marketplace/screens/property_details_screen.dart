import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _selectedTabIndex = 0;
  bool _showScarcity = false;

  @override
  void initState() {
    super.initState();
    // Simulate finding a hot property
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showScarcity = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      _buildFloatingStatsCard(),
                      const SizedBox(height: 24),
                      _buildSegmentedControl(),
                      const SizedBox(height: 24),
                      _buildRoiSimulator(),
                      const SizedBox(height: 24),
                      _buildAboutSection(),
                      const SizedBox(height: 24),
                      _buildLocationMap(),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                      const SizedBox(height: 120), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyInvestBar(context),
          if (_showScarcity) _buildScarcityAlert(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.1),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.1),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.1),
                child: IconButton(
                  icon: const Icon(Icons.ios_share, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuB53YcbIZQuktB_lHfjL2ZIKr3UJ10Z3vcOogfM2ZyXWTWYbXA_8cnBtb0esT4tRKq3kKx6nS9Ul04wKSL_EK5IV2S62q-AN-UgPLsMvMM8Hb3cYcBjrUPiy31EUv6LmRPBSKVaOtqj6AWggzM96UXQrc9KhQpbyDXUyrN7OzyZ-tpqdpe4klllC3FGgkKqiAljmJsgR_bna34x5w2k4JIYsapvqS140kI71MrvtfUAEJYjVPpBJIlMZtipr1LvaXyIIlgQsIUCrA',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark.withOpacity(0.3),
                    Colors.transparent,
                    AppColors.backgroundDark,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'PREMIUM ASSET',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The Meridien\nPenthouse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Downtown Dubai, UAE',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatItem('Asset Value', '\$4.5M')),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.white.withOpacity(0.1)),
                      right: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: _buildStatItem('Token', '\$50', padding: true),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'APY',
                  '12.5%',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '95% Funded',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'High Demand',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.95,
              backgroundColor: const Color(0xFF324467),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1,840 Investors',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                'Closing in 4 days',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value, {
    bool padding = false,
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: padding
          ? const EdgeInsets.symmetric(horizontal: 16)
          : const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: ['Overview', 'Financials', 'Documents'].map((tab) {
          final isSelected =
              ['Overview', 'Financials', 'Documents'].indexOf(tab) ==
              _selectedTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedTabIndex = [
                  'Overview',
                  'Financials',
                  'Documents',
                ].indexOf(tab);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoiSimulator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2333), Color(0xFF161B26)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'ROI Simulator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Investment Amount', style: TextStyle(color: Colors.grey)),
              Text(
                '\$2,500',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: 2500,
            min: 50,
            max: 10000,
            activeColor: AppColors.primary,
            inactiveColor: const Color(0xFF324467),
            onChanged: (value) {},
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$50', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text('\$10k', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Income',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '+\$26.04',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5-Year Return',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '+\$3,100',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the Property',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Experience the pinnacle of luxury in this exclusive penthouse located in the heart of Downtown Dubai. Featuring floor-to-ceiling windows with panoramic views of the Burj Khalifa, this asset represents a prime opportunity for high-yield rental income in a thriving market.',
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                        _buildAmenity(Icons.pool, 'Infinity Pool'),
                        _buildAmenity(Icons.fitness_center, 'Private Gym'),
                        _buildAmenity(Icons.local_parking, 'Valet Parking'),
                        _buildAmenity(Icons.security, '24/7 Security'),
                      ]
                      .map(
                        (w) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: w,
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenity(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCHWLtJ2N6hOY7O-BlmPITGOmQqINXtWTMLRtymfjzRKYi7Wv0eSTISMXALPPHSMC5Di10-y2-nLegoSP9ZmHemdsE4FWUILVaEzkxzXExncjSaeNjTZMa4SDylGxgb9hYLpLhVqFglx6H4PTfI6gOVgHWiZha_1O8oEWP30jljiMSpx4wH_6-7RPYWCG8MNeK4CX4M7Y4nQIbuvycQNzxj7u7VQUekQgJl4Y43BxzAS2ROX2FhlHjtk-lm-V9U2EsfufSDOzP2SQ',
          ),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.map, size: 16),
          label: const Text('View on Map'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            elevation: 0,
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                icon: Icons.warning_amber,
                label: 'Risk Audit',
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryButton(
                icon: Icons.history_edu,
                label: 'Appraisals',
                iconColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildListButton(
          Icons.play_circle,
          'Immersive 3D Tour',
          'Walkthrough the property',
        ),
        const SizedBox(height: 12),
        _buildListButton(
          Icons.construction,
          'Construction Updates',
          'Track progress & milestones',
          iconColor: Colors.green,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {},
          child: Text(
            'VIEW EXIT STRATEGY OPTIONS',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListButton(
    IconData icon,
    String title,
    String subtitle, {
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (iconColor ?? AppColors.primary).withOpacity(0.2),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStickyInvestBar(BuildContext context) {
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
          padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2333).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '\$12,450.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push('/checkout'),
                icon: const Text('Buy Tokens'),
                label: const Icon(Icons.arrow_forward, size: 16),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScarcityAlert() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF193326).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.warning, color: Colors.amber, size: 32),
                  const Text(
                    'Market Alert',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _showScarcity = false),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Last 5% Remaining',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'HIGH DEMAND',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _showScarcity = false);
                  context.push('/checkout');
                },
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Secure Your Stake'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showScarcity = false),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
