import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepository(FirebaseFirestore.instance);
});

class PropertyRepository {
  final FirebaseFirestore _firestore;

  PropertyRepository(this._firestore);

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

  Future<void> seedProperties() async {
    final collection = _firestore.collection('properties');
    final snapshot = await collection.get();

    // Only seed if empty
    if (snapshot.docs.isNotEmpty) return;

    final mockProperties = [
      Property(
        id: '',
        title: 'The Orion Penthouse',
        location: 'Miami, FL',
        price: 54.20,
        yieldRate: 8.5,
        available: 400,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBxsR1Uvzzr5Rf008mbOADxpT_xz5mzvQ7Zkaur3EzLxob79FZM2ni_qrdwpycXrJTx07CJigcx3bYQL8YEYuhk6pRcitxavfGKrhgb5yzk6vSHssX9kFqgvm9vcqr9kPCvI4wFJsNTKz6WziTNWU6GoJklFRzq1lZVdzV2mdz3oVD-wDuc6_gWrPK6pSV5YBclX_UA3zvR1DGPhQq902g-boM1BD9RS4sCOAw2Hgqwy9XwheOKGN3TJypIKOrlEVK91rFm51A48A',
        tag: 'PENTHOUSE',
        contractAddress: '0x1234567890123456789012345678901234567890',
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
      ),
    ];

    for (final property in mockProperties) {
      await collection.add(property.toMap());
    }
  }
}
