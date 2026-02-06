class MonthlyFinancialReport {
  final String id;
  final String propertyId;
  final DateTime reportDate;
  final double grossRent;
  final double operatingExpenses;
  final double managementFee; // 10% of gross rent
  final double netDistributableIncome;
  final String? transactionHash; // Blockchain deposit confirmation
  final DateTime createdAt;

  MonthlyFinancialReport({
    required this.id,
    required this.propertyId,
    required this.reportDate,
    required this.grossRent,
    required this.operatingExpenses,
    required this.managementFee,
    required this.netDistributableIncome,
    this.transactionHash,
    required this.createdAt,
  });

  factory MonthlyFinancialReport.fromMap(Map<String, dynamic> map, String id) {
    return MonthlyFinancialReport(
      id: id,
      propertyId: map['propertyId'] ?? '',
      reportDate: map['reportDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reportDate'])
          : DateTime.now(),
      grossRent: (map['grossRent'] ?? 0).toDouble(),
      operatingExpenses: (map['operatingExpenses'] ?? 0).toDouble(),
      managementFee: (map['managementFee'] ?? 0).toDouble(),
      netDistributableIncome: (map['netDistributableIncome'] ?? 0).toDouble(),
      transactionHash: map['transactionHash'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'reportDate': reportDate.millisecondsSinceEpoch,
      'grossRent': grossRent,
      'operatingExpenses': operatingExpenses,
      'managementFee': managementFee,
      'netDistributableIncome': netDistributableIncome,
      'transactionHash': transactionHash,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  String get monthYear {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[reportDate.month - 1]} ${reportDate.year}';
  }

  double get totalDeductions => operatingExpenses + managementFee;
}
