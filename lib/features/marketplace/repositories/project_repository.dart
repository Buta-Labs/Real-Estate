import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_status.dart';
import 'package:orre_mmc_app/features/marketplace/models/project_model.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(FirebaseFirestore.instance);
});

final projectListProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjects();
});

class ProjectRepository {
  final FirebaseFirestore _firestore;

  ProjectRepository(this._firestore);

  Future<List<Project>> getProjects() async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      return snapshot.docs.map((doc) => Project.fromDocument(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      return _generateMockProjects();
    }
  }

  Future<Project?> getProjectById(String id) async {
    try {
      final doc = await _firestore.collection('projects').doc(id).get();
      if (doc.exists) {
        return Project.fromDocument(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching project $id: $e');
      return null;
    }
  }

  List<Project> _generateMockProjects() {
    return [
      Project(
        id: 'mock_1',
        name: 'The Orion Complex',
        location: 'Dubai Marina, UAE',
        description:
            'A futuristic residential complex in the heart of the city.',
        heroImage:
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&q=80',
        locationCoordinates: '25.0772, 55.1328',
        logo: '',
        type: 'Apartments',
        status: PropertyStatus.active,
        floors: 45,
        totalUnits: 120,
        areaRange: '80-250 m²',
        gallery: [
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80',
        ],
        amenities: ['Pool', 'Gym', 'Sky Garden'],
      ),
      Project(
        id: 'mock_2',
        name: 'Azure Bay Residences',
        location: 'Greenwich, London, UK',
        description: 'Luxury waterfront living with private beach access.',
        heroImage:
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80',
        locationCoordinates: '51.5074, -0.1278',
        logo: '',
        type: 'Villas',
        status: PropertyStatus.active,
        floors: 3,
        totalUnits: 40,
        areaRange: '150-400 m²',
        gallery: [],
        amenities: ['Private Beach', 'Marina', 'Concierge'],
      ),
    ];
  }
}
