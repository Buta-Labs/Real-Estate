import 'package:cloud_firestore/cloud_firestore.dart';
import 'property_status.dart';

class Project {
  final String id;
  final String name;
  final String location;
  final String description;
  final String heroImage;
  final String locationCoordinates;
  final String logo;
  final String type;
  final PropertyStatus status;
  final int floors;
  final int totalUnits;
  final String areaRange;
  final List<String> gallery;
  final List<String> amenities;
  final String videoUrl;

  Project({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.heroImage,
    required this.locationCoordinates,
    required this.logo,
    required this.type,
    required this.status,
    required this.floors,
    required this.totalUnits,
    required this.areaRange,
    required this.gallery,
    required this.amenities,
    this.videoUrl = '',
  });

  Project copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? heroImage,
    String? locationCoordinates,
    String? logo,
    String? type,
    PropertyStatus? status,
    int? floors,
    int? totalUnits,
    String? areaRange,
    List<String>? gallery,
    List<String>? amenities,
    String? videoUrl,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      heroImage: heroImage ?? this.heroImage,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      logo: logo ?? this.logo,
      type: type ?? this.type,
      status: status ?? this.status,
      floors: floors ?? this.floors,
      totalUnits: totalUnits ?? this.totalUnits,
      areaRange: areaRange ?? this.areaRange,
      gallery: gallery ?? this.gallery,
      amenities: amenities ?? this.amenities,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  factory Project.fromMap(String id, Map<String, dynamic> map) {
    return Project(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      heroImage: map['heroImage'] ?? '',
      locationCoordinates: map['locationCoordinates'] ?? '',
      logo: map['logo'] ?? '',
      type: map['type'] ?? 'Apartments',
      status: PropertyStatusExtension.fromString(map['status'] ?? ''),
      floors: map['floors'] is int
          ? map['floors']
          : int.tryParse(map['floors'].toString()) ?? 0,
      totalUnits: map['totalUnits'] is int
          ? map['totalUnits']
          : int.tryParse(map['totalUnits'].toString()) ?? 0,
      areaRange: map['areaRange'] ?? '',
      gallery: List<String>.from(map['gallery'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      videoUrl: map['videoUrl'] ?? '',
    );
  }

  factory Project.fromDocument(DocumentSnapshot doc) {
    return Project.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'heroImage': heroImage,
      'locationCoordinates': locationCoordinates,
      'logo': logo,
      'type': type,
      'status': status.name,
      'floors': floors,
      'totalUnits': totalUnits,
      'areaRange': areaRange,
      'gallery': gallery,
      'amenities': amenities,
      'videoUrl': videoUrl,
    };
  }
}
