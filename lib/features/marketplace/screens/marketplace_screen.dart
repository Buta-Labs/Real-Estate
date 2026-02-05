import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/features/marketplace/widgets/property_card.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/marketplace/controllers/marketplace_controller.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/property_repository.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
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
                  backgroundColor: AppColors.backgroundDark.withValues(
                    alpha: 0.95,
                  ),
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
                      icon: const Icon(Icons.sync),
                      tooltip: 'Sync with Blockchain',
                      onPressed: () async {
                        // ToastService().showInfo(context, 'Syncing...');
                        await ref
                            .read(propertyRepositoryProvider)
                            .syncMarketplace();
                        // ToastService().showSuccess(context, 'Marketplace Synced');
                      },
                    ),
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
                              color: Colors.white.withValues(alpha: 0.05),
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
                                              : Colors.white.withValues(
                                                  alpha: 0.1,
                                                ),
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
                  sliver: ref
                      .watch(propertyListProvider)
                      .when(
                        data: (properties) {
                          if (properties.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      'No properties found',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await ref
                                            .read(propertyRepositoryProvider)
                                            .seedProperties();
                                      },
                                      child: const Text('Seed Mock Data'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              if (index == properties.length) {
                                return const SizedBox(
                                  height: 100,
                                ); // Bottom spacer
                              }
                              final property = properties[index];
                              return PropertyCard(
                                title: property.title,
                                location: property.location,
                                price: '\$${property.price.toStringAsFixed(2)}',
                                yield: '${property.yieldRate}%',
                                available: property.available.toString(),
                                image: property.imageUrl,
                                tag: property.tag,
                                condition: property.condition,
                                tierIndex: property.tierIndex,
                                onTap: () => context.push(
                                  '/property-details',
                                  extra: property,
                                ),
                              );
                            }, childCount: properties.length + 1),
                          );
                        },
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stack) => SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              'Error: $error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
