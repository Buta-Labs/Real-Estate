import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ), // Max width similar to React's max-w-sm
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            borderRadius: BorderRadius.circular(24),
            color: AppColors.card.withValues(alpha: 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(context, 0, Icons.dashboard, 'Home'),
                _buildNavItem(context, 1, Icons.storefront, 'Invest'),

                // AI FAB
                GestureDetector(
                  onTap: () => _onTap(context, 2),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.smart_toy, color: Colors.white),
                  ),
                ),

                _buildNavItem(
                  context,
                  3,
                  Icons.account_balance_wallet,
                  'Wallet',
                ),
                _buildNavItem(context, 4, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.grey[400],
            size: 24,
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
