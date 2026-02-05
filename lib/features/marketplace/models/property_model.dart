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
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      yieldRate: (map['yieldRate'] ?? 0).toDouble(),
      available: (map['available'] ?? 0).toInt(),
      imageUrl: map['imageUrl'] ?? '',
      tag: map['tag'] ?? '',
      contractAddress: map['contractAddress'] ?? '',
      tierIndex: (map['tierIndex'] ?? 0).toInt(),
      legalDocHash: map['legalDocHash'] ?? '',
    );
  }
}
