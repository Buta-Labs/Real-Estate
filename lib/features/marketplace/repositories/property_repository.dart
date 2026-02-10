import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_status.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final blockchainRepo = ref.watch(blockchainRepositoryProvider);
  return PropertyRepository(FirebaseFirestore.instance, blockchainRepo);
});

class PropertyRepository {
  final FirebaseFirestore _firestore;
  final BlockchainRepository _blockchainRepository;

  PropertyRepository(this._firestore, this._blockchainRepository);

  Stream<List<Property>> getProperties() {
    return _firestore.collection('properties').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // MVP Patch: Ensure Demo Property has correct address if missing
        if (data['title'] == 'The Orion Penthouse' &&
            (data['contractAddress'] == null ||
                data['contractAddress'] == '')) {
          data['contractAddress'] =
              '0x1234567890123456789012345678901234567890';
        }
        return Property.fromMap(doc.id, data);
      }).toList();
    });
  }

  Stream<List<Property>> getPropertiesByProjectId(String projectId) {
    return _firestore
        .collection('properties')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            if (data['title'] == 'The Orion Penthouse' &&
                (data['contractAddress'] == null ||
                    data['contractAddress'] == '')) {
              data['contractAddress'] =
                  '0x1234567890123456789012345678901234567890';
            }
            return Property.fromMap(doc.id, data);
          }).toList();
        });
  }

  Future<void> seedProperties() async {
    final collection = _firestore.collection('properties');
    final snapshot = await collection.get();

    // Only seed if empty
    if (snapshot.docs.isNotEmpty) return;

    final mockProperties = [
      Property(
        id: '',
        title: 'The Orion Penthouse',
        location: 'Dubai, UAE',
        price: 54.20,
        yieldRate: 8.5,
        available: 400,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBxsR1Uvzzr5Rf008mbOADxpT_xz5mzvQ7Zkaur3EzLxob79FZM2ni_qrdwpycXrJTx07CJigcx3bYQL8YEYuhk6pRcitxavfGKrhgb5yzk6vSHssX9kFqgvm9vcqr9kPCvI4wFJsNTKz6WziTNWU6GoJklFRzq1lZVdzV2mdz3oVD-wDuc6_gWrPK6pSV5YBclX_UA3zvR1DGPhQq902g-boM1BD9RS4sCOAw2Hgqwy9XwheOKGN3TJypIKOrlEVK91rFm51A48A',
        tag: 'PENTHOUSE',
        contractAddress: '0x1234567890123456789012345678901234567890',
        description:
            'Experience the pinnacle of luxury in this exclusive penthouse located in the heart of Downtown Dubai. Featuring floor-to-ceiling windows with panoramic views of the Burj Khalifa, this asset represents a prime opportunity for high-yield rental income in a thriving market.',
        amenities: [
          'Infinity Pool',
          'Private Gym',
          'Valet Parking',
          '24/7 Security',
        ],
        gallery: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBxsR1Uvzzr5Rf008mbOADxpT_xz5mzvQ7Zkaur3EzLxob79FZM2ni_qrdwpycXrJTx07CJigcx3bYQL8YEYuhk6pRcitxavfGKrhgb5yzk6vSHssX9kFqgvm9vcqr9kPCvI4wFJsNTKz6WziTNWU6GoJklFRzq1lZVdzV2mdz3oVD-wDuc6_gWrPK6pSV5YBclX_UA3zvR1DGPhQq902g-boM1BD9RS4sCOAw2Hgqwy9XwheOKGN3TJypIKOrlEVK91rFm51A48A',
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&q=80',
        ],
        totalArea: 450.0,
        locationCoordinates: '25.0772, 55.1328',
        status: PropertyStatus.active,
      ),
      Property(
        id: '',
        title: 'Greenwich Villa',
        location: 'London, UK',
        price: 120.50,
        yieldRate: 6.2,
        available: 12,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAv4iBMVoZomuWhRZPwSbL2BYoqOtLi26lZNdIfLhv9pysgWhPPSHjorfYtZ6zp1ya5Zthc8Xx27T9AHRy4vUyABjmHZaXuzZhRkHFlQc5pYAzpPorzjTkebAmc_jYcFrUaaGwyHcKjXAd2c_RQZM3kk96BYUhSNPvUk1N_JOI67cV0Lxa4XUHtC9q1n0eI0nFUNxffGRhJIWh_4clXwSJ96PX_znJJum6hr9v0cWxeOVvD8jt_OB360PKtPwmye2qpxxOOlUr18w',
        tag: 'VILLA',
        contractAddress: '0x2345678901234567890123456789012345678901',
        description:
            'A charming historic villa in Greenwich with modern interiors. Perfect for families looking for a quiet retreat within the city.',
        amenities: ['Garden', 'Fireplace', 'Garage', 'Smart Home System'],
        gallery: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAv4iBMVoZomuWhRZPwSbL2BYoqOtLi26lZNdIfLhv9pysgWhPPSHjorfYtZ6zp1ya5Zthc8Xx27T9AHRy4vUyABjmHZaXuzZhRkHFlQc5pYAzpPorzjTkebAmc_jYcFrUaaGwyHcKjXAd2c_RQZM3kk96BYUhSNPvUk1N_JOI67cV0Lxa4XUHtC9q1n0eI0nFUNxffGRhJIWh_4clXwSJ96PX_znJJum6hr9v0cWxeOVvD8jt_OB360PKtPwmye2qpxxOOlUr18w',
          'https://images.unsplash.com/photo-1580587767378-782771430f4e?auto=format&fit=crop&q=80',
        ],
        totalArea: 280.0,
        locationCoordinates: '51.4826, -0.0077',
        status: PropertyStatus.active,
      ),
      Property(
        id: '',
        title: 'Marina Bay Suites',
        location: 'Singapore',
        price: 89.00,
        yieldRate: 5.8,
        available: 1250,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAw5WCl_qoZKrIDm92tKryyR6Ish_XpDvT1UeCMUo8rPYX5zITPBg75Frl3-4ujgUYxZSL28EHjjKEz2RxE4RoOp8xo1hJeUi4_1TQsKxLaQl5GiTSm5Pwvnm7UIY_cviAOy2wEM4cuMEq76LFKws1FRPc0IW8YtsfwIEJgEAsgHduAiDEUw70YIpsims-s4sWfZATg-X-bThElMLFnTsHicRpnKhZ32dhkwGefcFapB_tezjcd2cKbDfXj8Fh1wqtGNJusiNtl6Q',
        tag: 'RESORT',
        contractAddress: '0x3456789012345678901234567890123456789012',
        description:
            'Luxury resort suite overlooking Marina Bay. High occupancy rates and premium management services ensure steady returns.',
        amenities: ['Spa', 'Concierge', 'Rooftop Bar', 'Business Center'],
        gallery: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAw5WCl_qoZKrIDm92tKryyR6Ish_XpDvT1UeCMUo8rPYX5zITPBg75Frl3-4ujgUYxZSL28EHjjKEz2RxE4RoOp8xo1hJeUi4_1TQsKxLaQl5GiTSm5Pwvnm7UIY_cviAOy2wEM4cuMEq76LFKws1FRPc0IW8YtsfwIEJgEAsgHduAiDEUw70YIpsims-s4sWfZATg-X-bThElMLFnTsHicRpnKhZ32dhkwGefcFapB_tezjcd2cKbDfXj8Fh1wqtGNJusiNtl6Q',
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80',
        ],
        totalArea: 120.0,
        locationCoordinates: '1.2823, 103.8585',
        status: PropertyStatus.active,
      ),
    ];

    for (final property in mockProperties) {
      await collection.add(property.toMap());
    }
  }

  Future<void> syncMarketplace() async {
    try {
      final addresses = await _blockchainRepository.getDeployedProperties();

      for (final address in addresses) {
        final details = await _blockchainRepository.getPropertyDetails(address);
        if (details.isEmpty) continue;

        final legalDocHash = details['legalDocHash'] as String;
        final name = details['name'] as String;
        final price = details['price'] as double;
        final tierIndex = details['tierIndex'] as int;

        // Try to find matching property in Firestore
        // Strategy: Match by legalDocHash.
        // Fallback: If not found, maybe create a new listing?
        // For this task, we update existing listings only.

        if (legalDocHash.isNotEmpty) {
          final query = await _firestore
              .collection('properties')
              .where('legalDocHash', isEqualTo: legalDocHash)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            final doc = query.docs.first;
            await doc.reference.update({
              'contractAddress': address,
              'price': price,
              'title': name,
              'tierIndex': tierIndex,
            });
            // debugPrint('Updated property ${doc.id} from blockchain');
          } else {
            // Optional: If you want to enable matching by title or other fields for legacy support
            // final titleQuery = await _firestore.collection('properties').where('title', isEqualTo: name).get();
            // if (titleQuery.docs.isNotEmpty) ...
            debugPrint(
              'Property not found in Firestore for hash: $legalDocHash',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }
}
