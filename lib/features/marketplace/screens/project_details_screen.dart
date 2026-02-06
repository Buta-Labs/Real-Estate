import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:orre_mmc_app/features/marketplace/models/project_model.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/property_repository.dart';
import 'package:orre_mmc_app/features/marketplace/widgets/property_card.dart';
import 'package:orre_mmc_app/features/marketplace/widgets/project_video_player.dart';

import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart'; // Add url_launcher
import 'package:orre_mmc_app/shared/screens/full_screen_gallery_screen.dart'; // Add FullScreenGallery

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  Future<void> _openMap() async {
    final query = widget.project.locationCoordinates.isNotEmpty
        ? widget.project.locationCoordinates
        : widget.project.location;

    if (query.isEmpty) return;

    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not open map: $e');
    }
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsSection(),
                      if (widget.project.videoUrl.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Project Tour',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ProjectVideoPlayer(
                          videoUrl: widget.project.videoUrl,
                          thumbnailUrl: widget.project.heroImage,
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                      const SizedBox(height: 24),
                      _buildGallerySection(),
                      const SizedBox(height: 24),
                      _buildAmenitiesSection(),
                      const SizedBox(height: 24),

                      const SizedBox(height: 24),
                      _buildLocationMapCard(),
                      const SizedBox(height: 32),
                      const Text(
                        'Available Units',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Available Units List
                      Consumer(
                        builder: (context, ref, child) {
                          final propertyRepo = ref.watch(
                            propertyRepositoryProvider,
                          );
                          return StreamBuilder<List<Property>>(
                            stream: propertyRepo.getPropertiesByProjectId(
                              widget.project.id,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'No units currently available in this project.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final property = snapshot.data![index];
                                  return PropertyCard(
                                    title: property.title,
                                    location: property.location,
                                    price:
                                        '\$${NumberFormat.currency(symbol: '', decimalDigits: 0).format(property.price)}',
                                    yield: '${property.yieldRate}%',
                                    available: '${property.available}',
                                    image: property.imageUrl,
                                    tag: property.tag,
                                    rooms: property.rooms,
                                    totalArea: property.totalArea,
                                    onTap: () => context.push(
                                      '/property-details',
                                      extra: property,
                                    ),
                                    tierIndex: property.tierIndex,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Helper contact / action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark.withValues(alpha: 0),
                    AppColors.backgroundDark,
                    AppColors.backgroundDark,
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: const Text(
                  'Contact Sales Team',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.project.heroImage.isNotEmpty
                  ? widget.project.heroImage
                  : 'https://via.placeholder.com/400x300',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    AppColors.backgroundDark,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.project.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.project.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  if (widget.project.locationCoordinates.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Small location text with icon
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.project.location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('Type', widget.project.type),
          _buildDivider(),
          _buildStatItem('Units', '${widget.project.totalUnits}'),
          _buildDivider(),
          _buildStatItem('Area', widget.project.areaRange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the Complex',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.project.description,
          style: const TextStyle(color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 24),
        // Prominent Status Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Status',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    widget.project.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    if (widget.project.amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.project.amenities.map((amenity) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                amenity,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    if (widget.project.gallery.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.project.gallery.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGalleryScreen(
                        images: widget.project.gallery,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.project.gallery[index],
                    width: 200,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMapCard() {
    final locationText = widget.project.location;
    final coords = widget.project.locationCoordinates;

    // Default center (Baku, Azerbaijan) if no coordinates
    LatLng center = const LatLng(40.4093, 49.8671);
    bool hasValidCoords = false;

    if (coords.isNotEmpty && coords.contains(',')) {
      try {
        final parts = coords.split(',');
        if (parts.length == 2) {
          final lat = double.parse(parts[0].trim());
          final lng = double.parse(parts[1].trim());
          center = LatLng(lat, lng);
          hasValidCoords = true;
        }
      } catch (e) {
        debugPrint('Error parsing coordinates: $e');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                locationText.isNotEmpty
                    ? locationText
                    : widget.project.locationCoordinates,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2333),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag
                          .none, // Disable interaction in mini map
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.orre.app',
                    ),
                    if (hasValidCoords)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // Overlay to dim the map slightly and make the button pop
                Container(color: Colors.black.withValues(alpha: 0.2)),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('View on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
