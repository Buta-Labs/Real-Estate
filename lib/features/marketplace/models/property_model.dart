class PropertySpecification {
  final String label;
  final String value;
  final String unit;

  PropertySpecification({
    required this.label,
    required this.value,
    this.unit = '',
  });

  Map<String, dynamic> toMap() {
    return {'label': label, 'value': value, 'unit': unit};
  }

  factory PropertySpecification.fromMap(Map<String, dynamic> map) {
    return PropertySpecification(
      label: map['label'] as String? ?? '',
      value: map['value']?.toString() ?? '',
      unit: map['unit'] as String? ?? '',
    );
  }
}

class PropertySpecifications {
  final double sqm;
  final int bedrooms;
  final int bathrooms;
  final int livingRooms;
  final int kitchens;
  final int balconies;
  final int powderRooms;
  final String furnishing;
  final List<PropertySpecification> dynamicSpecs;

  PropertySpecifications({
    this.sqm = 0.0,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.livingRooms = 0,
    this.kitchens = 0,
    this.balconies = 0,
    this.powderRooms = 0,
    this.furnishing = 'Unfurnished',
    this.dynamicSpecs = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'sqm': sqm,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'livingRooms': livingRooms,
      'kitchens': kitchens,
      'balconies': balconies,
      'powderRooms': powderRooms,
      'furnishing': furnishing,
      'dynamicSpecs': dynamicSpecs.map((s) => s.toMap()).toList(),
    };
  }

  factory PropertySpecifications.fromMap(dynamic data) {
    if (data == null) return PropertySpecifications();

    if (data is List) {
      return PropertySpecifications(
        dynamicSpecs: data
            .map(
              (item) => PropertySpecification.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(),
      );
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      double safeDouble(dynamic val) {
        if (val == null) return 0.0;
        if (val is int) return val.toDouble();
        if (val is double) return val;
        if (val is String) return double.tryParse(val) ?? 0.0;
        return 0.0;
      }

      int safeInt(dynamic val) {
        if (val == null) return 0;
        if (val is int) return val;
        if (val is double) return val.toInt();
        if (val is String) return int.tryParse(val) ?? 0;
        return 0;
      }

      return PropertySpecifications(
        sqm: safeDouble(map['sqm']),
        bedrooms: safeInt(map['bedrooms']),
        bathrooms: safeInt(map['bathrooms']),
        livingRooms: safeInt(map['livingRooms']),
        kitchens: safeInt(map['kitchens']),
        balconies: safeInt(map['balconies']),
        powderRooms: safeInt(map['powderRooms']),
        furnishing: map['furnishing'] ?? 'Unfurnished',
        dynamicSpecs: map['dynamicSpecs'] != null
            ? List<PropertySpecification>.from(
                (map['dynamicSpecs'] as List).map(
                  (x) =>
                      PropertySpecification.fromMap(x as Map<String, dynamic>),
                ),
              )
            : const [],
      );
    }

    return PropertySpecifications();
  }
}

class Property {
  final String id;
  final String title;
  final String location;
  final double price;
  final double yieldRate;
  final int available;
  final String imageUrl;
  final String tag;
  final String contractAddress;
  final int tierIndex;
  final String legalDocHash;
  final String condition;
  final String tokenName;
  final String tokenSymbol;
  final int rooms;
  final double totalArea;
  final String buildingNumber;
  final String projectId;
  final String description;
  final List<String> amenities;
  final List<String> gallery;
  final String locationCoordinates;
  final String videoUrl;
  final int totalTokens;
  final double? currentValuation;
  final double? initialValuation;
  final DateTime? lastAppraisalDate;

  final String? occupancyStatus;
  final PropertySpecifications specifications;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.yieldRate,
    required this.available,
    required this.imageUrl,
    required this.tag,
    required this.contractAddress,
    this.tierIndex = 0,
    this.legalDocHash = '',
    this.condition = '',
    this.tokenName = '',
    this.tokenSymbol = '',
    this.rooms = 0,
    this.totalArea = 0.0,
    this.buildingNumber = '',
    this.projectId = '',
    this.description = '',
    this.amenities = const [],
    this.gallery = const [],
    this.locationCoordinates = '',
    this.videoUrl = '',
    this.totalTokens = 1000,
    this.currentValuation,
    this.initialValuation,
    this.lastAppraisalDate,
    this.occupancyStatus,
    PropertySpecifications? specifications,
  }) : specifications = specifications ?? PropertySpecifications();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'price': price,
      'yieldRate': yieldRate,
      'available': available,
      'imageUrl': imageUrl,
      'tag': tag,
      'contractAddress': contractAddress,
      'tierIndex': tierIndex,
      'legalDocHash': legalDocHash,
      'condition': condition,
      'tokenName': tokenName,
      'tokenSymbol': tokenSymbol,
      'rooms': rooms,
      'totalArea': totalArea,
      'buildingNumber': buildingNumber,
      'projectId': projectId,
      'description': description,
      'amenities': amenities,
      'gallery': gallery,
      'locationCoordinates': locationCoordinates,
      'videoUrl': videoUrl,
      'totalTokens': totalTokens,
      'currentValuation': currentValuation,
      'initialValuation': initialValuation,
      'lastAppraisalDate': lastAppraisalDate?.toIso8601String(),
      'occupancyStatus': occupancyStatus,
      'specifications': specifications.toMap(),
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    // Helper to safely parse numbers
    double safeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int safeInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return Property(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      price: safeDouble(map['price']),
      yieldRate: safeDouble(map['yieldRate']),
      available: safeInt(map['available']),
      imageUrl: map['imageUrl'] ?? '',
      tag: map['tag'] ?? '',
      contractAddress: map['contractAddress'] ?? '',
      tierIndex: safeInt(map['tierIndex']),
      legalDocHash: map['legalDocHash'] ?? '',
      condition: map['condition'] ?? '',
      tokenName: map['tokenName'] ?? '',
      tokenSymbol: map['tokenSymbol'] ?? '',
      rooms: safeInt(map['rooms']),
      totalArea: safeDouble(map['totalArea']),
      buildingNumber: map['buildingNumber'] ?? '',
      projectId: map['projectId'] ?? '',
      description: map['description'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      gallery: List<String>.from(map['gallery'] ?? []),
      locationCoordinates: map['locationCoordinates'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      totalTokens: safeInt(map['totalTokens']),
      currentValuation: map['currentValuation'] != null
          ? safeDouble(map['currentValuation'])
          : null,
      initialValuation: map['initialValuation'] != null
          ? safeDouble(map['initialValuation'])
          : null,
      lastAppraisalDate: map['lastAppraisalDate'] != null
          ? DateTime.tryParse(map['lastAppraisalDate'] as String)
          : null,
      occupancyStatus: map['occupancyStatus'],
      specifications: PropertySpecifications.fromMap(map['specifications']),
    );
  }
}
