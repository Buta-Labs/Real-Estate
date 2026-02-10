import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_status.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/features/marketplace/widgets/property_card.dart';
import 'package:orre_mmc_app/features/marketplace/widgets/project_card.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/property_repository.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/project_repository.dart';
import 'package:orre_mmc_app/features/marketplace/models/project_model.dart';
import 'package:orre_mmc_app/features/marketplace/controllers/marketplace_controller.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/marketplace_stats_repository.dart';
import 'package:orre_mmc_app/shared/widgets/location_filter_dialog.dart';
import 'package:orre_mmc_app/features/marketplace/domain/stay_logic.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _activeFilter = 'All';
  int _selectedTabIndex = 0; // 0: Properties, 1: Projects
  bool _isGridView = false;
  List<String> _selectedLocations = []; // Empty means all locations
  final _priceFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  ); // Million dollar friendly

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
                      tooltip: 'Refresh',
                      onPressed: () {
                        ref.invalidate(propertyListProvider);
                        ref.invalidate(projectListProvider);
                        ref.invalidate(marketplaceStatsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Refreshing marketplace...'),
                            duration: Duration(seconds: 1),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isGridView ? Icons.view_list : Icons.grid_view,
                      ),
                      tooltip: _isGridView ? 'List View' : 'Grid View',
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
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

                        // Tab Switcher
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2333),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            children: ['Properties', 'Projects'].map((tab) {
                              final index = [
                                'Properties',
                                'Projects',
                              ].indexOf(tab);
                              final isSelected = index == _selectedTabIndex;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tab,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stats Row - Real Data
                        Consumer(
                          builder: (context, ref, child) {
                            final statsAsync = ref.watch(
                              marketplaceStatsProvider,
                            );
                            return statsAsync.when(
                              data: (stats) => Row(
                                children: [
                                  _buildStatCard(
                                    '\$${(stats.volume24h / 1000).toStringAsFixed(1)}K',
                                    '24h Vol',
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    '${stats.totalListings}',
                                    'Listings',
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    '${stats.averageYield.toStringAsFixed(1)}%',
                                    'Avg Yield',
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                              loading: () => Row(
                                children: [
                                  _buildStatCard('...', '24h Vol'),
                                  const SizedBox(width: 12),
                                  _buildStatCard('...', 'Listings'),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    '...',
                                    'Avg Yield',
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                              error: (_, _) => Row(
                                children: [
                                  _buildStatCard('\$0', '24h Vol'),
                                  const SizedBox(width: 12),
                                  _buildStatCard('0', 'Listings'),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    '0%',
                                    'Avg Yield',
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                            );
                          },
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
                                      onSelected: (bool selected) async {
                                        if (filter == 'Location') {
                                          // Show location filter dialog
                                          final propertiesAsync = ref.read(
                                            propertyListProvider,
                                          );
                                          final allLocations = propertiesAsync
                                              .when(
                                                data: (properties) =>
                                                    properties
                                                        .map((p) => p.location)
                                                        .toSet()
                                                        .toList()
                                                      ..sort(),
                                                loading: () => <String>[],
                                                error: (_, _) => <String>[],
                                              );

                                          final result =
                                              await showDialog<List<String>>(
                                                context: context,
                                                builder: (_) =>
                                                    LocationFilterDialog(
                                                      allLocations:
                                                          allLocations,
                                                      selectedLocations:
                                                          _selectedLocations,
                                                    ),
                                              );

                                          if (result != null) {
                                            setState(() {
                                              _selectedLocations = result;
                                              _activeFilter = filter;
                                            });
                                          }
                                        } else {
                                          setState(
                                            () => _activeFilter = filter,
                                          );
                                        }
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

                // Projects List/Grid (when Projects tab selected)
                if (_selectedTabIndex == 1)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: _buildProjectList(ref),
                  ),

                // Property List (when Properties tab selected)
                if (_selectedTabIndex == 0)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: _buildPropertyList(ref),
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
                onPressed: () {
                  context.push('/map-view');
                },
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

  Widget _buildPropertyList(WidgetRef ref) {
    return ref
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

            // Apply filters
            var filteredProperties = List.from(properties);

            // Apply location filter
            if (_selectedLocations.isNotEmpty) {
              filteredProperties = filteredProperties
                  .where((p) => _selectedLocations.contains(p.location))
                  .toList();
            }

            // Apply sorting filters
            if (_activeFilter == 'Highest Yield') {
              filteredProperties.sort(
                (a, b) => b.yieldRate.compareTo(a.yieldRate),
              );
            } else if (_activeFilter == 'Lowest Price') {
              filteredProperties.sort((a, b) => a.price.compareTo(b.price));
            }

            // Standard status sorting: Active > Coming Soon > Sold Out
            filteredProperties.sort((a, b) {
              final statusOrder = {
                PropertyStatus.active: 0,
                PropertyStatus.comingSoon: 1,
                PropertyStatus.soldOut: 2,
                PropertyStatus.hidden: 3,
              };
              return (statusOrder[a.status] ?? 3).compareTo(
                statusOrder[b.status] ?? 3,
              );
            });

            // Hide hidden items
            filteredProperties = filteredProperties
                .where((p) => p.status != PropertyStatus.hidden)
                .toList();

            // Grid or List view
            if (_isGridView) {
              return _buildPropertyGrid(filteredProperties);
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == filteredProperties.length) {
                  return const SizedBox(height: 100);
                }
                final property = filteredProperties[index];
                return PropertyCard(
                  title: property.title,
                  location: property.location,
                  price: _priceFormat.format(property.price),
                  yield: '${property.yieldRate}%',
                  available: property.available.toString(),
                  image: property.imageUrl,
                  tag: property.tag,
                  condition: property.condition,
                  tierIndex: property.tierIndex,
                  rooms: property.rooms,
                  totalArea: property.totalArea,
                  rawPrice: property.price,
                  onTap: () =>
                      context.push('/property-details', extra: property),
                  status: property.status,
                );
              }, childCount: filteredProperties.length + 1),
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

  Widget _buildProjectList(WidgetRef ref) {
    return ref
        .watch(projectListProvider)
        .when(
          data: (projects) {
            if (projects.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No projects found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            }

            // Apply status sorting: Active > Coming Soon > Sold Out
            var sortedProjects = List<Project>.from(projects);
            sortedProjects.sort((a, b) {
              final statusOrder = {
                PropertyStatus.active: 0,
                PropertyStatus.comingSoon: 1,
                PropertyStatus.soldOut: 2,
                PropertyStatus.hidden: 3,
              };
              return (statusOrder[a.status] ?? 3).compareTo(
                statusOrder[b.status] ?? 3,
              );
            });

            // Hide hidden projects
            sortedProjects = sortedProjects
                .where((p) => p.status != PropertyStatus.hidden)
                .toList();

            // Grid or List view
            if (_isGridView) {
              return _buildProjectGrid(sortedProjects);
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == sortedProjects.length) {
                  return const SizedBox(height: 100);
                }
                final project = sortedProjects[index];
                return ProjectCard(project: project);
              }, childCount: sortedProjects.length + 1),
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
        );
  }

  Widget _buildProjectGrid(List<Project> projects) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= projects.length) return null;
          final project = projects[index];

          // Compact project grid card
          return GestureDetector(
            onTap: () =>
                context.push('/project-details/${project.id}', extra: project),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              project.heroImage.isNotEmpty
                                  ? project.heroImage
                                  : 'https://via.placeholder.com/400x200',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: project.status == PropertyStatus.active
                                ? AppColors.primary
                                : project.status == PropertyStatus.comingSoon
                                ? Colors.orange
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            project.status.displayName.toUpperCase(),
                            style: TextStyle(
                              color: project.status == PropertyStatus.active
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (project.status == PropertyStatus.comingSoon)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'COMING SOON',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 10,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      project.type,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Project Grid Details
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.home_work_outlined,
                                      size: 10,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${project.totalUnits}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.layers_outlined,
                                      size: 10,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${project.floors}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.square_foot,
                                      size: 10,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      project.areaRange,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: projects.length),
      ),
    );
  }

  Widget _buildPropertyGrid(List properties) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // Adjusted for better mobile fit
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= properties.length) return null;
          final property = properties[index];

          // Compact grid card
          return GestureDetector(
            onTap: () => context.push('/property-details', extra: property),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(property.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (property.tag.isNotEmpty ||
                          property.condition.isNotEmpty)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Row(
                            children: [
                              if (property.tag.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    property.tag,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (property.condition.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    property.condition,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: property.tierIndex == 2
                                    ? Colors.purpleAccent.withValues(alpha: 0.8)
                                    : property.tierIndex == 1
                                    ? Colors.blueAccent.withValues(alpha: 0.8)
                                    : AppColors.primary.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                property.tierIndex == 2
                                    ? 'STAY'
                                    : property.tierIndex == 1
                                    ? 'GROWTH'
                                    : '${property.yieldRate}%',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (property.tierIndex != 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${property.yieldRate}%',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            if (property.tierIndex == 2) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.purpleAccent.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.hotel,
                                      color: Colors.purpleAccent,
                                      size: 8,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${calculateStayRights(5000, property.price)}d',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 10,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      property.location,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Grid Details (Rooms & Area)
                              Row(
                                children: [
                                  Icon(
                                    Icons.bed_outlined,
                                    size: 10,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${property.rooms}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 9,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.square_foot,
                                    size: 10,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${property.totalArea.toStringAsFixed(0)}m²',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _priceFormat.format(property.price),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${property.available} Available',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: properties.length),
      ),
    );
  }
}
