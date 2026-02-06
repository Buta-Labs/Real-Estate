import 'package:cloud_firestore/cloud_firestore.dart';

class Valuation {
  final String id;
  final DateTime date;
  final double valuationAmount;
  final String source;
  final double changePercent;
  final String? documentUrl;

  Valuation({
    required this.id,
    required this.date,
    required this.valuationAmount,
    required this.source,
    required this.changePercent,
    this.documentUrl,
  });

  /// Calculate the Net Asset Value (NAV) per token
  double getTokenNAV(int totalTokens) {
    if (totalTokens <= 0) return 0;
    return valuationAmount / totalTokens;
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'valuationAmount': valuationAmount,
      'source': source,
      'changePercent': changePercent,
      'documentUrl': documentUrl,
    };
  }

  /// Create from Firestore document
  factory Valuation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Valuation(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      valuationAmount: (data['valuationAmount'] as num).toDouble(),
      source: data['source'] as String,
      changePercent: (data['changePercent'] as num).toDouble(),
      documentUrl: data['documentUrl'] as String?,
    );
  }

  /// Create from map (for testing or admin panel)
  factory Valuation.fromMap(Map<String, dynamic> map, String id) {
    return Valuation(
      id: id,
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date'] as String),
      valuationAmount: (map['valuationAmount'] as num).toDouble(),
      source: map['source'] as String,
      changePercent: (map['changePercent'] as num).toDouble(),
      documentUrl: map['documentUrl'] as String?,
    );
  }
}
