class PropertyDocument {
  final String id;
  final String propertyId;
  final String title;
  final String documentUrl;
  final String documentType; // 'legal', 'financial', 'inspection', 'other'
  final DateTime uploadedAt;
  final int fileSize;
  final String fileName;

  PropertyDocument({
    required this.id,
    required this.propertyId,
    required this.title,
    required this.documentUrl,
    required this.documentType,
    required this.uploadedAt,
    required this.fileSize,
    required this.fileName,
  });

  factory PropertyDocument.fromMap(Map<String, dynamic> map, String id) {
    return PropertyDocument(
      id: id,
      propertyId: map['propertyId'] ?? '',
      title: map['title'] ?? '',
      documentUrl: map['documentUrl'] ?? '',
      documentType: map['documentType'] ?? 'other',
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['uploadedAt'])
          : DateTime.now(),
      fileSize: map['fileSize'] ?? 0,
      fileName: map['fileName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'title': title,
      'documentUrl': documentUrl,
      'documentType': documentType,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
      'fileSize': fileSize,
      'fileName': fileName,
    };
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get categoryIcon {
    switch (documentType) {
      case 'legal':
        return '📄';
      case 'financial':
        return '📊';
      case 'inspection':
        return '🔍';
      default:
        return '📎';
    }
  }

  String get categoryName {
    switch (documentType) {
      case 'legal':
        return 'Legal Documents';
      case 'financial':
        return 'Financial Documents';
      case 'inspection':
        return 'Inspection Reports';
      default:
        return 'Other Documents';
    }
  }
}
