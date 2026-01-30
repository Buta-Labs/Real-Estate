import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class SelectAssetScreen extends StatelessWidget {
  const SelectAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Select Asset',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Property to List',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose an asset from your portfolio to trade on the marketplace.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _buildFilterChips(),
              const SizedBox(height: 24),
              _buildAssetCard(
                context,
                title: 'The Pad at Marina Bay',
                location: 'Singapore, SG',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBDtGeZSe5hItljoutIPKrCmDhmE63de1YoFtbSv36BxOQWTCXKz8sR7YVlN6J1J0W_Qcg-rHee0oBM7u5YXDmCgrYv30zctgxq4pRUHusN0ENvAhFKCKbffbo6aKb9FXGrgDms-bLivuvQ066zu5Q2hmOtDQLsrR2rJnth12Q89ce7R7dx__Ekg3dGqiQ2V9TYKs6fT2yEDyGM9332ve_HzsbVZ9qu3-uBgOa1uGFb3qa-0N3mucav_FHaq6RO1_hy4wl0Bm2Yyg',
                apr: '+12.4%',
                value: '\$12,450.00',
                tokens: '500',
              ),
              const SizedBox(height: 16),
              _buildAssetCard(
                context,
                title: 'Skyline Lofts',
                location: 'New York, USA',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDAIxM-b55i1vqgoiTkotn2isbdSclDsL2H2a_M3xeO4WnCxRGEb6v3COLKiHzQjXgrpYm32r-_IsQSRhh9bjw9lpfXQWkfJNHc7hwKWZD48Z--xiNVUZM_IL1LgTYRtCLaSbk64TwhQ4WScQUHg2mDlyzP6QEUZaQiyhlfM6m9fX9kKaNUmMUs3BP3o3EnU7KrifL02-Q5MGtn21NEjXTbnq0F-eW4VMeGBr7MlLUtLVsMs7idkbIKKMPeiVn3FP9ErDAXyo2shA',
                apr: '+8.2%',
                value: '\$8,240.00',
                tokens: '240',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Highest Value', isActive: true),
          const SizedBox(width: 12),
          _buildChip('Most Tokens'),
          const SizedBox(width: 12),
          _buildChip('Recently Acquired'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAssetCard(
    BuildContext context, {
    required String title,
    required String location,
    required String imageUrl,
    required String apr,
    required String value,
    required String tokens,
  }) {
    return GestureDetector(
      onTap: () => context.push('/sell-tokens'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$apr APR',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT VALUE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'AVAILABLE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.token,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$tokens Tokens',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
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
}
