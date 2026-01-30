import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';

class GovernanceScreen extends StatefulWidget {
  const GovernanceScreen({super.key});

  @override
  State<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends State<GovernanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Governance Hub'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVotingPowerCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Active Proposals'),
                  Tab(text: 'Past Decisions'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height:
                  600, // Fixed height for tab view content usually calculated dynamically
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProposalsList(),
                  const Center(
                    child: Text(
                      'No past decisions',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingPowerCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B3A2B), Color(0xFF0A120E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.how_to_vote,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR VOTING POWER',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '1,250 ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: 'ORRE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.verified, color: Color(0xFF0BDA46), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Active Stake in 4 Properties',
                      style: TextStyle(
                        color: Color(0xFF0BDA46),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalsList() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'OPEN FOR VOTING',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        _buildProposalCard(
          title: 'Renovate Pool Area',
          description:
              'Upgrade to premium quartz decking and install heated filtration systems for year-round use.',
          image:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBkbr-07WShwaO2IM03GyPgcBj9u2bMhJ9TL1c5LjoGt9U07CVIgcs6TuzOTitWJciCakjanJG5Xm1iifDmW8hmLGiM3gNn2zGGJuRv2KUC1HBdKdkirOeq4z488zqrV_YAalaOhzVB-3Twq0hlM3zQGtUSFQFaH_tYi6iHLMo7IFXD5shQbTV3K_SgGVmS6HbJiiq36sJ7XY6i-2hrvzQrSVmIVB1xXV2qux-C5eyEVUIiLEKwqe-nKe7cZ1h4XBpnz8J9Bh1aDw',
          location: 'The Emerald Heights',
          timeLeft: 'Ends in 02d 14h',
          forPercent: 0.68,
          againstPercent: 0.32,
          isUrgent: true,
        ),
        const SizedBox(height: 16),
        _buildProposalCard(
          title: 'New Property Manager',
          description:
              'Proposal to appoint \'LuxeStay Management\' to increase short-term rental yields by 15%.',
          image:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuD13A1LkJfrQa0MZOZvhPl_ZUFzpkGVk72rzFjP4ZeM9PLSetOzKERp8bngCL112esL7zzgTrwDEOUXp_6IZ5b0DfmGPPXYZ-OcmPG_AyYCy6v9veJZj-wVvb7LpunlIY6AI9Oay5ikSTa2tUau2YUD8ShkQRIC6tPcK2zc_TC6gQJluUZLNEZu2G0al7DrUwRdFgkTNVshnEik2MOyppsOU4ZYE2NBd5N6egXWDtje6TnOmRG6BK1py63QdDJ01yY-7w3HpOGfDw',
          location: 'Azure Plaza',
          timeLeft: 'Ends in 05d 08h',
          forPercent: 0.42,
          againstPercent: 0.58,
        ),
      ],
    );
  }

  Widget _buildProposalCard({
    required String title,
    required String description,
    required String image,
    required String location,
    required String timeLeft,
    required double forPercent,
    required double againstPercent,
    bool isUrgent = false,
  }) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(image, fit: BoxFit.cover),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 12,
                          color: isUrgent ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeLeft.toUpperCase(),
                          style: TextStyle(
                            color: isUrgent ? Colors.black : Colors.white,
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
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'URGENT',
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
                Text(
                  description,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(forPercent * 100).toInt()}% For',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(againstPercent * 100).toInt()}% Against',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: (forPercent * 100).toInt(),
                        child: Container(height: 6, color: AppColors.primary),
                      ),
                      Expanded(
                        flex: (againstPercent * 100).toInt(),
                        child: Container(
                          height: 6,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                        label: const Text('Vote For'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.thumb_down_alt_outlined,
                          size: 16,
                        ),
                        label: const Text('Against'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
}
