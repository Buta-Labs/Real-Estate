import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: Row(
                children: [
                  _buildLabelsColumn(),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPropertyColumn(
                          name: 'Azure Plaza',
                          location: 'Miami, FL',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBBfN2HVqJviGR1buhJ9dk2CSFN9W91qQI5mf4yvRSFvFvNmZenNRMoO7udql07UCvTqERoUffo1HZhV4xGBKW1dX3ibwe_8iMicT9EFpr1K_F_PtZWsCG7bli12SqkyBtZjRJQCTzZCxYAuh9ui8R7AnBsRtuxmQAc1L6oZI5Z-LHHl4zlGTgmiwmHMBVUK3JntlWXyEelDvKrwDQh5Jc972IxFfBMG_cY8cCiAdEpgmDDr67--rs7b4LceMxOXGWfzy1YPNkHFw',
                          roi: '12.5%',
                          value: '\$4.2M',
                          occupancy: '98.2%',
                          minInvest: '\$2,500',
                          price: '\$50.00',
                        ),
                        _buildPropertyColumn(
                          name: 'Oakwood Heights',
                          location: 'Austin, TX',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDQdO5R-ZgwVciS9gZp1kw_DFqTlcjGCS-BcUb8PyNgJ3_SndgQ9PGigIzc9BS7C4cvd_Zpky0YeSAtC2rqDVO0d2cETrDveyIKUP6Z7TFT9UzRSprSdIkPV71Qio9xTcARDMctrO8xmMkA8LhdAEs-JSANgGSxG1jYZYRUonqPeKTasTiuxvy_TJNIvO0OFcdZluOKFKmzKcaNJXnoWoXaRcj-iGnS5ASxXKOigUcQm92fzNI732v1KoRRO6EEP_la5UEbD_owwg',
                          roi: '10.8%',
                          value: '\$2.1M',
                          occupancy: '94.0%',
                          minInvest: '\$1,000',
                          price: '\$25.00',
                        ),
                        _buildPropertyColumn(
                          name: 'The Meridian',
                          location: 'Seattle, WA',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAqjsz-JGcIIMqbRVnsAEWCU8culL2oid38TOS3hG0pj3_58lefZdNG2loxzbTipWIQXec8FfQdgxvPxu_vCbpHRZ2f0KwQ-qgxPmOcmTidaYv_-nKiq-qMrWUx1NeQfsW8UySqz_k_Etx8OEQgARRCZjQqcXZcox2ZHbS0mYIfdaav5G2lQ8Jq6DWm6vPx7gQtmtF-_WS_Rgl4vOS8WatYIQZosuCa38YTxZpAkjKuefBZcg0kxnwk-vKugO5ogCiW1wNyLRnXrw',
                          roi: '14.2%',
                          value: '\$8.5M',
                          occupancy: '100%',
                          minInvest: '\$5,000',
                          price: '\$100.00',
                        ),
                        _buildAddAsset(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const Text(
            'Compare Properties',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'CLEAR',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab('Financials', true),
          _buildTab('Appreciation', false),
          _buildTab('Market', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLabelsColumn() {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'PROPERTIES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildLabelCell('Target ROI'),
          _buildLabelCell('Market Value'),
          _buildLabelCell('Occupancy'),
          _buildLabelCell('Min. Invest'),
          _buildLabelCell('Token Price'),
        ],
      ),
    );
  }

  Widget _buildLabelCell(String text) {
    return Container(
      height: 64,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildPropertyColumn({
    required String name,
    required String location,
    required String imageUrl,
    required String roi,
    required String value,
    required String occupancy,
    required String minInvest,
    required String price,
  }) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  location.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDataCell(roi, isPrimary: true),
          _buildDataCell(value),
          _buildDataCell(occupancy),
          _buildDataCell(minInvest),
          _buildDataCell(price),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'INVEST',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, {bool isPrimary = false}) {
    return Container(
      height: 64,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isPrimary ? AppColors.primary : Colors.white.withOpacity(0.8),
          fontSize: isPrimary ? 16 : 14,
          fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAddAsset() {
    return SizedBox(
      width: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  style: BorderStyle.none,
                ), // Mock dashed border
                color: Colors.white.withOpacity(0.05),
              ),
              child: const Icon(Icons.add, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              'ADD ASSET',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PORTFOLIO PROJECTION',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '+1.2% Overall',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AVG. YIELD',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '11.5%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL CAPITAL',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$18.8M',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
}
