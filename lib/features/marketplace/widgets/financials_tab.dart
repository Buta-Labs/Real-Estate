import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';
import 'package:orre_mmc_app/features/marketplace/models/monthly_financial_report.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_valuation.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/financial_repository.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:intl/intl.dart';

class FinancialsTab extends ConsumerStatefulWidget {
  final Property property;

  const FinancialsTab({super.key, required this.property});

  @override
  ConsumerState<FinancialsTab> createState() => _FinancialsTabState();
}

class _FinancialsTabState extends ConsumerState<FinancialsTab> {
  String? _expandedReportId;
  double? _totalDividends;
  double? _userTokens;
  double? _totalSupply;

  @override
  void initState() {
    super.initState();
    _loadBlockchainData();
  }

  Future<void> _loadBlockchainData() async {
    if (widget.property.contractAddress.isEmpty) return;

    final blockchain = ref.read(blockchainRepositoryProvider);

    // Get total dividends from smart contract
    final totalDiv = await blockchain.getTotalDividendsDistributed(
      widget.property.contractAddress,
    );

    // Get user's wallet address from connected session
    String? userAddress;
    if (blockchain.appKitModal.isConnected &&
        blockchain.appKitModal.session != null) {
      // Extract address from session - the address is in the format "eip155:84532:0x..."
      final accounts = blockchain.appKitModal.session!.getAccounts();
      if (accounts != null && accounts.isNotEmpty) {
        final parts = accounts.first.split(':');
        if (parts.length >= 3) {
          userAddress = parts[2]; // Get the address part
        }
      }
    }

    double? userBal;
    double? supply;

    if (userAddress != null) {
      userBal = await blockchain.getUserTokenBalance(
        widget.property.contractAddress,
        userAddress,
      );
      supply = await blockchain.getTotalSupply(widget.property.contractAddress);
    }

    if (mounted) {
      setState(() {
        _totalDividends = totalDiv;
        _userTokens = userBal;
        _totalSupply = supply;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(
      propertyFinancialReportsProvider(widget.property.id),
    );
    final valuationAsync = ref.watch(
      propertyValuationProvider(widget.property.id),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNetYieldDashboard(),
          const SizedBox(height: 24),

          // The Waterfall - Cost Breakdown (All Tiers)
          reportsAsync.when(
            data: (reports) => reports.isNotEmpty
                ? _buildWaterfallCard(reports.first)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Tier-Specific Modules
          if (widget.property.tierIndex == 1) ...[
            _buildAppreciationTracker(),
            const SizedBox(height: 24),
          ],
          if (widget.property.tierIndex == 2 &&
              _userTokens != null &&
              _totalSupply != null &&
              _totalSupply! > 0) ...[
            _buildStayBenefit(),
            const SizedBox(height: 24),
          ],
          if (widget.property.tierIndex == 0 &&
              widget.property.occupancyStatus != null) ...[
            _buildOccupancyStatus(),
            const SizedBox(height: 24),
          ],

          // Monthly Income Breakdown
          reportsAsync.when(
            data: (reports) => _buildMonthlyReports(reports),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Property Valuation
          valuationAsync.when(
            data: (valuation) => valuation != null
                ? _buildPropertyValuation(valuation)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Your Share
          if (_userTokens != null && _totalSupply != null && _totalSupply! > 0)
            _buildYourShare(),
        ],
      ),
    );
  }

  Widget _buildNetYieldDashboard() {
    final totalDiv = _totalDividends ?? 0.0;
    final propertyValue = widget.property.price * widget.property.totalTokens;
    final apy = propertyValue > 0 ? (totalDiv / propertyValue) * 100 : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2638), Color(0xFF141926)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle Decorative Element
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NET YIELD DASHBOARD',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    _buildLiveBadge(),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.trending_up,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${apy.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Annualized APY',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TOTAL DIVIDENDS',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '\$${NumberFormat('#,##0.00').format(totalDiv)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_graph, color: AppColors.primary, size: 10),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReports(List<MonthlyFinancialReport> reports) {
    if (reports.isEmpty) {
      return _buildEmptyReports();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'REVENUE HISTORY',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          ...reports.map((report) => _buildReportItem(report)),
        ],
      ),
    );
  }

  Widget _buildReportItem(MonthlyFinancialReport report) {
    final isExpanded = _expandedReportId == report.id;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _expandedReportId = isExpanded ? null : report.id;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report.monthYear,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(report.netDistributableIncome)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  _buildBreakdownRow(
                    'Gross Rent',
                    report.grossRent,
                    isPositive: true,
                  ),
                  _buildBreakdownRow(
                    'Operating Expenses',
                    report.operatingExpenses,
                    isNegative: true,
                  ),
                  _buildBreakdownRow(
                    'Management Fee (10%)',
                    report.managementFee,
                    isNegative: true,
                  ),
                  const Divider(height: 24, color: Colors.white10),
                  _buildBreakdownRow(
                    'Net Distributable',
                    report.netDistributableIncome,
                    isFinal: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    double amount, {
    bool isNegative = false,
    bool isPositive = false,
    bool isFinal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isFinal ? Colors.white : Colors.grey,
              fontSize: isFinal ? 15 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}${isPositive ? '+' : ''}\$${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(
              color: isFinal
                  ? AppColors.primary
                  : (isNegative ? Colors.red[300] : Colors.white),
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReports() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 48, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text(
            'No Financial Reports Yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Reports will appear once rent is distributed',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyValuation(PropertyValuation valuation) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CAPITAL STACK',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildValuationRow('Property Price', valuation.purchasePrice),
          _buildValuationRow('Renovation/Furnishing', valuation.renovationCost),
          _buildValuationRow('Acquisition Fee (3%)', valuation.acquisitionFee),
          const Divider(height: 24, color: Colors.white10),
          _buildValuationRow(
            'Total Raise',
            valuation.totalRaiseAmount,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildValuationRow(
    String label,
    double amount, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.grey,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourShare() {
    final ownershipPercent = (_userTokens! / _totalSupply!) * 100;

    // Get latest report for "last month's income" calculation
    final reportsAsync = ref.watch(
      propertyFinancialReportsProvider(widget.property.id),
    );
    double lastMonthIncome = 0.0;

    reportsAsync.whenData((reports) {
      if (reports.isNotEmpty) {
        lastMonthIncome =
            (reports.first.netDistributableIncome * ownershipPercent) / 100;
      }
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR SHARE',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Tokens', style: TextStyle(color: Colors.grey)),
              Text(
                '${_userTokens!.toStringAsFixed(0)} / ${_totalSupply!.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ownership', style: TextStyle(color: Colors.grey)),
              Text(
                '${ownershipPercent.toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (lastMonthIncome > 0) ...[
            const Divider(height: 24, color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Last Month\'s Income',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '\$${NumberFormat('#,##0.00').format(lastMonthIncome)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaterfallCard(MonthlyFinancialReport report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'THE WATERFALL',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                report.monthYear,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWaterfallRow(
            'Gross Rent Collected',
            report.grossRent,
            isFirst: true,
          ),
          const SizedBox(height: 8),
          _buildWaterfallRow(
            'Service/Maintenance Costs',
            report.operatingExpenses,
            isNegative: true,
          ),
          const SizedBox(height: 8),
          _buildWaterfallRow(
            'Orre Management Fee (10%)',
            report.managementFee,
            isNegative: true,
          ),
          const Divider(height: 24, color: Colors.white10),
          _buildWaterfallRow(
            'Net Distributed to Investors',
            report.netDistributableIncome,
            isFinal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterfallRow(
    String label,
    double amount, {
    bool isNegative = false,
    bool isFirst = false,
    bool isFinal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (!isFirst && !isFinal)
              Icon(
                isNegative ? Icons.remove : Icons.add,
                size: 14,
                color: isNegative ? Colors.red[300] : AppColors.primary,
              ),
            if (!isFirst && !isFinal) const SizedBox(width: 8),
            if (isFinal)
              const Icon(
                Icons.arrow_forward,
                size: 14,
                color: AppColors.primary,
              ),
            if (isFinal) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isFinal ? Colors.white : Colors.grey,
                fontSize: isFinal ? 15 : 14,
                fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          '${isNegative ? '-' : ''}\$${NumberFormat('#,##0.00').format(amount)}',
          style: TextStyle(
            color: isFinal
                ? AppColors.primary
                : (isNegative ? Colors.red[300] : Colors.white),
            fontSize: isFinal ? 16 : 14,
            fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAppreciationTracker() {
    final purchasePrice = widget.property.price * widget.property.totalTokens;
    final currentVal = widget.property.currentValuation ?? purchasePrice;
    final growth = purchasePrice > 0
        ? ((currentVal - purchasePrice) / purchasePrice) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueAccent.withValues(alpha: 0.1),
            Colors.blueAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.blueAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'APPRECIATION TRACKER',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Purchase Price',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '\$${NumberFormat('#,##0.00').format(purchasePrice)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Est. Value',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '\$${NumberFormat('#,##0.00').format(currentVal)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Growth', style: TextStyle(color: Colors.grey)),
              Text(
                '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: growth >= 0 ? Colors.blueAccent : Colors.red[300],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStayBenefit() {
    final ownershipPercent = (_userTokens! / _totalSupply!) * 100;
    final totalDays = ((ownershipPercent / 100) * 365).floor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purpleAccent.withValues(alpha: 0.1),
            Colors.purpleAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.hotel, color: Colors.purpleAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'MY STAY BENEFIT',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  '$totalDays',
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Days Remaining This Year',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: totalDays >= 1 ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: totalDays >= 1
                    ? Colors.purpleAccent
                    : Colors.grey[800],
                foregroundColor: totalDays >= 1 ? Colors.white : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Book Dates',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyStatus() {
    final status = widget.property.occupancyStatus ?? 'Unknown';
    final isActive =
        status.toLowerCase().contains('tenant') ||
        status.toLowerCase().contains('active');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OCCUPANCY STATUS',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                status,
                style: TextStyle(
                  color: isActive ? AppColors.primary : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isActive
                ? 'Property is currently generating rental income'
                : 'Property is vacant - dividends may be lower',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
