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
  });

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
    );
  }
}
