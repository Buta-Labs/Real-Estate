import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:orre_mmc_app/features/marketplace/controllers/marketplace_controller.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class MapViewScreen extends ConsumerWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Map'),
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: propertiesAsync.when(
        data: (properties) {
          // Filter properties with valid coordinates
          final propertiesWithCoords = properties.where((p) {
            return p.locationCoordinates.isNotEmpty;
          }).toList();

          // Default center (Baku, Azerbaijan)
          LatLng center = const LatLng(40.4093, 49.8671);

          // If we have properties with coordinates, center on the first one
          if (propertiesWithCoords.isNotEmpty) {
            try {
              final coords = propertiesWithCoords.first.locationCoordinates
                  .split(',');
              if (coords.length == 2) {
                center = LatLng(
                  double.parse(coords[0].trim()),
                  double.parse(coords[1].trim()),
                );
              }
            } catch (e) {
              // Use default center if parsing fails
            }
          }

          return FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 12.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.orre.app',
              ),
              MarkerLayer(
                markers: propertiesWithCoords
                    .map((property) {
                      try {
                        final coords = property.locationCoordinates.split(',');
                        if (coords.length == 2) {
                          final lat = double.parse(coords[0].trim());
                          final lng = double.parse(coords[1].trim());

                          return Marker(
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                _showPropertyInfo(context, property);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.home,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        // Skip invalid coordinates
                      }
                      return null;
                    })
                    .whereType<Marker>()
                    .toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading properties: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  void _showPropertyInfo(BuildContext context, dynamic property) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              property.location,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '\$${property.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yield',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${property.yieldRate}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.push('/property-details', extra: property);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
