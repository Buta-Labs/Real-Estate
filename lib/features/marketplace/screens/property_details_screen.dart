import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/shared/screens/full_screen_gallery_screen.dart';

import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_status.dart';
import 'package:orre_mmc_app/features/marketplace/widgets/documents_tab.dart';
import 'package:orre_mmc_app/features/marketplace/widgets/financials_tab.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/investment_repository.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/wallet/providers/wallet_provider.dart';

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  ConsumerState<PropertyDetailsScreen> createState() =>
      _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen> {
  int _selectedTabIndex = 0;
  bool _showScarcity = false;
  double _investmentAmount = 2500;
  double? _liveTotalRaised;
  double? _liveTargetRaise;

  double get _monthlyIncome =>
      (_investmentAmount * (widget.property.yieldRate / 100)) / 12;
  double get _fiveYearReturn =>
      (_investmentAmount * (widget.property.yieldRate / 100)) * 5;

  double get _percentSold {
    double percent = 0.0;
    if (_liveTargetRaise != null &&
        _liveTotalRaised != null &&
        _liveTargetRaise! > 0) {
      percent = (_liveTotalRaised! / _liveTargetRaise!) * 100;
    } else if (widget.property.totalTokens > 0) {
      percent =
          ((widget.property.totalTokens - widget.property.available) /
              widget.property.totalTokens) *
          100;
    }
    // Final safety guards
    if (percent.isInfinite || percent.isNaN || percent < 0) return 0.0;
    return percent.clamp(0.0, 100.0);
  }

  @override
  void initState() {
    super.initState();
    _loadLiveBlockchainData();

    // Set initial investment based on tier minimum
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final invRepo = ref.read(investmentRepositoryProvider);
      setState(() {
        _investmentAmount = invRepo.getMinimumInvestment(
          widget.property.tierIndex,
        );
      });
    });
  }

  Future<void> _loadLiveBlockchainData() async {
    if (widget.property.contractAddress.isEmpty) return;

    final blockchain = ref.read(blockchainRepositoryProvider);
    final details = await blockchain.getPropertyDetails(
      widget.property.contractAddress,
    );

    if (kDebugMode) {
      debugPrint('Blockchain Data for ${widget.property.title}: $details');
    }

    if (details.isNotEmpty && mounted) {
      setState(() {
        _liveTotalRaised = details['totalRaised'] as double?;
        _liveTargetRaise = details['targetRaise'] as double?;

        // Scarcity alert: only if < 5% remaining
        if (_liveTargetRaise != null &&
            _liveTotalRaised != null &&
            _liveTargetRaise! > 0) {
          final remainingPercent =
              ((_liveTargetRaise! - _liveTotalRaised!) / _liveTargetRaise!) *
              100;

          if (remainingPercent < 5 && remainingPercent > 0) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _showScarcity = true;
                });
              }
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      _buildFloatingStatsCard(),
                      const SizedBox(height: 24),
                      _buildSegmentedControl(),
                      const SizedBox(height: 24),
                      // Conditional content based on selected tab
                      if (_selectedTabIndex == 0) ...[
                        _buildRoiSimulator(),
                        const SizedBox(height: 24),
                        _buildGallerySection(),
                        const SizedBox(height: 24),
                        _buildAboutSection(),
                        const SizedBox(height: 24),
                        _buildLocationMap(),
                        const SizedBox(height: 24),
                        _buildActionButtons(context),
                      ] else if (_selectedTabIndex == 1) ...[
                        // Financials tab - no fixed height for proper scrolling
                        FinancialsTab(property: widget.property),
                      ] else if (_selectedTabIndex == 2) ...[
                        // Documents tab
                        DocumentsTab(propertyId: widget.property.id),
                      ],
                      const SizedBox(height: 120), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyInvestBar(context),
          if (_showScarcity) _buildScarcityAlert(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                child: IconButton(
                  icon: const Icon(Icons.ios_share, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.property.imageUrl.isNotEmpty
                  ? widget.property.imageUrl
                  : 'https://via.placeholder.com/400',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.grey[900]),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark.withValues(alpha: 0.3),
                    Colors.transparent,
                    AppColors.backgroundDark,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.property.condition.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.property.condition.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.property.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.property.location,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingStatsCard() {
    // Basic calculation for Asset Value (assuming price is per token and we have total tokens info, or just show price)
    // For now we display Token Price and Yield
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Sale Price',
                  NumberFormat.currency(
                    symbol: '\$',
                    decimalDigits: 0,
                  ).format(widget.property.price),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      right: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: _buildStatItem(
                    'Available',
                    '${widget.property.available}',
                    padding: true,
                  ),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Yield',
                  widget.property.status == PropertyStatus.comingSoon
                      ? 'TBA'
                      : '${widget.property.yieldRate}%',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.property.status == PropertyStatus.active
                    ? "Open for Investment"
                    : widget.property.status == PropertyStatus.comingSoon
                    ? "Opening Soon"
                    : "Sold Out",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.property.tag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.property.tag,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _percentSold / 100,
              backgroundColor: const Color(0xFF324467),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Investors',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '${_percentSold.toStringAsFixed(0)}% Sold',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Closing soon',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value, {
    bool padding = false,
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: padding
          ? const EdgeInsets.symmetric(horizontal: 16)
          : const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: ['Overview', 'Financials', 'Documents'].map((tab) {
          final isSelected =
              ['Overview', 'Financials', 'Documents'].indexOf(tab) ==
              _selectedTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedTabIndex = [
                  'Overview',
                  'Financials',
                  'Documents',
                ].indexOf(tab);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoiSimulator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2333), Color(0xFF161B26)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'ROI Simulator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Investment Amount', style: TextStyle(color: Colors.grey)),
              Text(
                '\$${_investmentAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _investmentAmount,
            min: ref
                .read(investmentRepositoryProvider)
                .getMinimumInvestment(widget.property.tierIndex),
            max: 10000,
            divisions: 39, // Adjust steps for better feel
            activeColor: AppColors.primary,
            inactiveColor: const Color(0xFF324467),
            onChanged: (value) {
              setState(() {
                _investmentAmount = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${ref.read(investmentRepositoryProvider).getMinimumInvestment(widget.property.tierIndex).toInt()}',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Text('\$10k', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          if (widget.property.tierIndex == 2) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hotel, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OWN STAY BENEFIT',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _investmentAmount >= 5000
                              ? "You unlocked ${ref.read(investmentRepositoryProvider).calculateStayDays(_investmentAmount, widget.property.price)} Days/Year"
                              : "Invest at least \$5,000 to unlock stay rights",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Income',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+\$${_monthlyIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '5-Year Return',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+\$${_fiveYearReturn.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        Container(
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
                'About the Property',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.property.description.isNotEmpty
                    ? widget.property.description
                    : 'Experience the pinnacle of luxury in this exclusive asset. Featuring premium finishes and located in a prime area, this property represents a unique investment opportunity.',
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 20),
              if (widget.property.amenities.isNotEmpty) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.property.amenities
                      .map((amenity) => _buildAmenity(amenity))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFeatureItem(
                    Icons.square_foot,
                    '${widget.property.specifications.sqm > 0 ? widget.property.specifications.sqm : widget.property.totalArea} sqm',
                  ),
                  const SizedBox(width: 24),
                  _buildFeatureItem(
                    Icons.bed,
                    '${widget.property.specifications.bedrooms > 0 ? widget.property.specifications.bedrooms : widget.property.rooms} Bedrooms',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildRoomBreakdown(),
      ],
    );
  }

  Widget _buildRoomBreakdown() {
    final specs = widget.property.specifications;
    final roomItems = [
      // Hardcoded fields (for backward compatibility)
      if (specs.bedrooms > 0)
        _RoomSpecItem(Icons.bed, '${specs.bedrooms} Bedrooms'),
      if (specs.bathrooms > 0)
        _RoomSpecItem(Icons.bathtub, '${specs.bathrooms} Washrooms'),
      if (specs.livingRooms > 0)
        _RoomSpecItem(Icons.weekend, '${specs.livingRooms} Living room'),
      if (specs.kitchens > 0)
        _RoomSpecItem(Icons.kitchen, '${specs.kitchens} Kitchen'),
      if (specs.balconies > 0)
        _RoomSpecItem(Icons.balcony, '${specs.balconies} Balcony'),
      if (specs.powderRooms > 0)
        _RoomSpecItem(Icons.wash, '${specs.powderRooms} Powder Room'),

      // Dynamic fields from Admin Panel
      ...specs.dynamicSpecs.map(
        (spec) => _RoomSpecItem(
          _getDynamicSpecIcon(spec.label),
          '${spec.label}: ${spec.value}${spec.unit.isNotEmpty ? ' ${spec.unit}' : ''}',
        ),
      ),
    ];

    if (roomItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333), // Match About Section color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Property Specs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: roomItems.length,
            itemBuilder: (context, index) {
              final item = roomItems[index];
              return Row(
                children: [
                  Icon(item.icon, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getDynamicSpecIcon(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('bed')) return Icons.bed;
    if (lower.contains('bath') || lower.contains('wash')) return Icons.bathtub;
    if (lower.contains('kitchen')) return Icons.kitchen;
    if (lower.contains('living')) return Icons.weekend;
    if (lower.contains('balcony')) return Icons.balcony;
    if (lower.contains('parking')) return Icons.local_parking;
    if (lower.contains('area') || lower.contains('sqm')) {
      return Icons.square_foot;
    }
    if (lower.contains('office') || lower.contains('study')) return Icons.work;
    if (lower.contains('laundry')) return Icons.local_laundry_service;
    if (lower.contains('foyer') ||
        lower.contains('entry') ||
        lower.contains('hall')) {
      return Icons.sensor_door;
    }
    if (lower.contains('ensuite')) return Icons.hot_tub;
    return Icons.info_outline;
  }

  IconData _getAmenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('pool')) return Icons.pool;
    if (lower.contains('gym')) return Icons.fitness_center;
    if (lower.contains('parking')) return Icons.local_parking;
    if (lower.contains('security')) return Icons.security;
    if (lower.contains('garden')) return Icons.deck;
    if (lower.contains('spa')) return Icons.spa;
    if (lower.contains('smart')) return Icons.smart_button;
    return Icons.check_circle_outline;
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAmenity(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_getAmenityIcon(label), color: const Color(0xFF10B981), size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _openMap() async {
    final query = widget.property.locationCoordinates.isNotEmpty
        ? widget.property.locationCoordinates
        : widget.property.location;

    if (query.isEmpty) return;

    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not open map: $e');
    }
  }

  Widget _buildGallerySection() {
    if (widget.property.gallery.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.property.gallery.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGalleryScreen(
                        images: widget.property.gallery,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.property.gallery[index],
                    width: 200,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMap() {
    final locationText = widget.property.location;
    final coords = widget.property.locationCoordinates;

    // Default center (Baku, Azerbaijan) if no coordinates
    LatLng center = const LatLng(40.4093, 49.8671);
    bool hasValidCoords = false;

    if (coords.isNotEmpty && coords.contains(',')) {
      try {
        final parts = coords.split(',');
        if (parts.length == 2) {
          final lat = double.parse(parts[0].trim());
          final lng = double.parse(parts[1].trim());
          center = LatLng(lat, lng);
          hasValidCoords = true;
        }
      } catch (e) {
        debugPrint('Error parsing coordinates: $e');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                locationText,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2333),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag
                          .none, // Disable interaction in mini map
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.orre.app',
                    ),
                    if (hasValidCoords)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // Overlay to dim the map slightly and make the button pop
                Container(color: Colors.black.withValues(alpha: 0.2)),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('View on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    context.push('/risk-assessment', extra: widget.property),
                child: _buildSecondaryButton(
                  icon: Icons.warning_amber,
                  label: 'Risk Audit',
                  iconColor: Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    context.push('/appraisal-history', extra: widget.property),
                child: _buildSecondaryButton(
                  icon: Icons.history_edu,
                  label: 'Appraisals',
                  iconColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildListButton(
          Icons.play_circle,
          'Immersive 3D Tour',
          'Walkthrough the property',
        ),
        const SizedBox(height: 12),
        _buildListButton(
          Icons.construction,
          'Construction Updates',
          'Track progress & milestones',
          iconColor: Colors.green,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push('/exit-strategy', extra: widget.property),
          child: _buildListButton(
            Icons.exit_to_app,
            'Exit Strategy',
            'Your path to liquidity',
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListButton(
    IconData icon,
    String title,
    String subtitle, {
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (iconColor ?? AppColors.primary).withValues(
              alpha: 0.2,
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStickyInvestBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundDark.withValues(alpha: 0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2333).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final balance = ref.watch(usdcBalanceProvider);
                        return Text(
                          '\$${balance.value ?? '0.00'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.property.status == PropertyStatus.soldOut
                    ? null
                    : widget.property.status == PropertyStatus.comingSoon
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Waitlist Joined'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : () => context.push('/checkout', extra: widget.property),
                icon: Text(
                  widget.property.status == PropertyStatus.active
                      ? 'Buy Tokens'
                      : widget.property.status == PropertyStatus.comingSoon
                      ? 'Notify Me'
                      : 'Sold Out',
                ),
                label: Icon(
                  widget.property.status == PropertyStatus.active
                      ? Icons.arrow_forward
                      : widget.property.status == PropertyStatus.comingSoon
                      ? Icons.notifications_none
                      : Icons.block,
                  size: 16,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.property.status == PropertyStatus.active
                      ? AppColors.primary
                      : widget.property.status == PropertyStatus.comingSoon
                      ? Colors.grey[700]
                      : Colors.grey[800],
                  foregroundColor:
                      widget.property.status == PropertyStatus.active
                      ? Colors.black
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScarcityAlert() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF193326).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.warning, color: Colors.amber, size: 32),
                  const Text(
                    'Market Alert',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _showScarcity = false),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Last 5% Remaining',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'HIGH DEMAND',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _showScarcity = false);
                  context.push('/checkout', extra: widget.property);
                },
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Secure Your Stake'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showScarcity = false),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomSpecItem {
  final IconData icon;
  final String label;

  _RoomSpecItem(this.icon, this.label);
}
