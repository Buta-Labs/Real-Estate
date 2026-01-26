import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/features/marketplace/widgets/property_card.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  backgroundColor: AppColors.backgroundDark.withOpacity(0.95),
                  floating: true,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {}, // Ideally go back
                  ),
                  title: const Text(
                    'Marketplace',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.grid_view),
                      onPressed: () {},
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {},
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.backgroundDark,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Search & Filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey[400]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Search properties...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(Icons.tune, color: Colors.grey[400]),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stats Row
                        Row(
                          children: [
                            _buildStatCard('\$1.2M', '24h Vol'),
                            const SizedBox(width: 12),
                            _buildStatCard('142', 'Listings'),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              '9.2%',
                              'Avg Yield',
                              isPrimary: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                [
                                  'All',
                                  'Highest Yield',
                                  'Lowest Price',
                                  'Location',
                                ].map((filter) {
                                  final isActive = _activeFilter == filter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(filter),
                                      selected: isActive,
                                      onSelected: (bool selected) {
                                        setState(() => _activeFilter = filter);
                                      },
                                      backgroundColor: AppColors.card,
                                      selectedColor: AppColors.primary,
                                      labelStyle: TextStyle(
                                        color: isActive
                                            ? Colors.black
                                            : Colors.grey[400],
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isActive
                                              ? AppColors.primary
                                              : Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Property List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      PropertyCard(
                        title: 'The Orion Penthouse',
                        location: 'Miami, FL',
                        price: '\$54.20',
                        yield: '8.5%',
                        available: '400',
                        image:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBxsR1Uvzzr5Rf008mbOADxpT_xz5mzvQ7Zkaur3EzLxob79FZM2ni_qrdwpycXrJTx07CJigcx3bYQL8YEYuhk6pRcitxavfGKrhgb5yzk6vSHssX9kFqgvm9vcqr9kPCvI4wFJsNTKz6WziTNWU6GoJklFRzq1lZVdzV2mdz3oVD-wDuc6_gWrPK6pSV5YBclX_UA3zvR1DGPhQq902g-boM1BD9RS4sCOAw2Hgqwy9XwheOKGN3TJypIKOrlEVK91rFm51A48A',
                        tag: 'PENTHOUSE',
                        onTap: () => context.push('/property-details'),
                      ),
                      PropertyCard(
                        title: 'Greenwich Villa',
                        location: 'London, UK',
                        price: '\$120.50',
                        yield: '6.2%',
                        available: '12',
                        image:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAv4iBMVoZomuWhRZPwSbL2BYoqOtLi26lZNdIfLhv9pysgWhPPSHjorfYtZ6zp1ya5Zthc8Xx27T9AHRy4vUyABjmHZaXuzZhRkHFlQc5pYAzpPorzjTkebAmc_jYcFrUaaGwyHcKjXAd2c_RQZM3kk96BYUhSNPvUk1N_JOI67cV0Lxa4XUHtC9q1n0eI0nFUNxffGRhJIWh_4clXwSJ96PX_znJJum6hr9v0cWxeOVvD8jt_OB360PKtPwmye2qpxxOOlUr18w',
                        tag: 'VILLA',
                        onTap: () => context.push('/property-details'),
                      ),
                      PropertyCard(
                        title: 'Marina Bay Suites',
                        location: 'Singapore',
                        price: '\$89.00',
                        yield: '5.8%',
                        available: '1,250',
                        image:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAw5WCl_qoZKrIDm92tKryyR6Ish_XpDvT1UeCMUo8rPYX5zITPBg75Frl3-4ujgUYxZSL28EHjjKEz2RxE4RoOp8xo1hJeUi4_1TQsKxLaQl5GiTSm5Pwvnm7UIY_cviAOy2wEM4cuMEq76LFKws1FRPc0IW8YtsfwIEJgEAsgHduAiDEUw70YIpsims-s4sWfZATg-X-bThElMLFnTsHicRpnKhZ32dhkwGefcFapB_tezjcd2cKbDfXj8Fh1wqtGNJusiNtl6Q',
                        tag: 'RESORT',
                        onTap: () => context.push('/property-details'),
                      ),

                      const SizedBox(
                        height: 100,
                      ), // Bottom spacer for nav bar and FABs
                    ]),
                  ),
                ),
              ],
            ),

            // Floating Buttons
            Positioned(
              right: 16,
              bottom: 110, // Above bottom nav
              child: FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.add_circle),
                label: const Text(
                  'List My Tokens',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 110, // Above bottom nav
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: AppColors.card,
                foregroundColor: Colors.white,
                child: const Icon(Icons.map),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {bool isPrimary = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPrimary ? AppColors.primary : Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
