import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? walletAddress;
  final String kycStatus; // 'none', 'pending', 'verified', 'rejected'
  final bool biometricEnabled;
  final String? fullLegalName; // Full legal name for contracts
  final String? country;
  final String? address;
  final String? idNumber;
  final DateTime? tier2AcknowledgmentTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.walletAddress,
    this.kycStatus = 'none',
    this.biometricEnabled = false,
    this.fullLegalName,
    this.country,
    this.address,
    this.idNumber,
    this.tier2AcknowledgmentTime,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data was null");
    }
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      walletAddress: data['walletAddress'],
      kycStatus: data['kycStatus'] ?? 'none',
      biometricEnabled: data['biometricEnabled'] ?? false,
      fullLegalName: data['fullLegalName'],
      country: data['country'],
      address: data['address'],
      idNumber: data['idNumber'],
      tier2AcknowledgmentTime: (data['tier2AcknowledgmentTime'] as Timestamp?)
          ?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'walletAddress': walletAddress,
      'kycStatus': kycStatus,
      'biometricEnabled': biometricEnabled,
      'fullLegalName': fullLegalName,
      'country': country,
      'address': address,
      'idNumber': idNumber,
      'tier2AcknowledgmentTime': tier2AcknowledgmentTime,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Check if user has completed required profile fields for contracts
  bool hasCompletedContractProfile() {
    return fullLegalName != null &&
        fullLegalName!.isNotEmpty &&
        country != null &&
        country!.isNotEmpty &&
        idNumber != null &&
        idNumber!.isNotEmpty;
  }
}
