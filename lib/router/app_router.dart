import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/auth/screens/login_screen.dart';
import 'package:orre_mmc_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/marketplace_screen.dart';
import 'package:orre_mmc_app/features/ai_advisor/screens/ai_advisor_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/wallet_screen.dart';
import 'package:orre_mmc_app/features/profile/screens/profile_screen.dart';
import 'package:orre_mmc_app/router/scaffold_with_bottom_nav.dart';
import 'package:orre_mmc_app/features/documents/screens/documents_screen.dart';
import 'package:orre_mmc_app/features/referrals/screens/referrals_screen.dart';
import 'package:orre_mmc_app/features/learning/screens/learning_screen.dart';
import 'package:orre_mmc_app/features/dashboard/screens/insights_screen.dart';
import 'package:orre_mmc_app/features/governance/screens/governance_screen.dart';
import 'package:orre_mmc_app/features/analytics/screens/analytics_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/deposit_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/withdraw_screen.dart';
import 'package:orre_mmc_app/features/profile/screens/security_settings_screen.dart';

import 'package:orre_mmc_app/features/profile/screens/digital_key_screen.dart';
import 'package:orre_mmc_app/features/documents/screens/tax_reports_screen.dart';
import 'package:orre_mmc_app/features/profile/screens/rewards_screen.dart';
import 'package:orre_mmc_app/features/profile/screens/sitemap_screen.dart';
import 'package:orre_mmc_app/features/referrals/screens/leaderboard_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/property_details_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/checkout_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/property_updates_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/property_tour_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/comparison_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/filters_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/heat_map_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/risk_assessment_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/appraisal_history_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/exit_strategy_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/bank_transfer_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/convert_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/select_asset_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/sell_tokens_screen.dart';
import 'package:orre_mmc_app/features/profile/screens/profile_screen.dart';
import 'package:orre_mmc_app/shared/screens/success_screen.dart';
import 'package:orre_mmc_app/features/referrals/screens/milestone_rewards_screen.dart';
import 'package:orre_mmc_app/features/referrals/screens/referral_milestone_screen.dart';
import 'package:orre_mmc_app/features/learning/screens/article_screen.dart';
import 'package:orre_mmc_app/features/portfolio/screens/diversification_screen.dart';
import 'package:orre_mmc_app/features/onboarding/screens/kyc_intro_screen.dart';
import 'package:orre_mmc_app/features/onboarding/screens/scanner_screen.dart';
import 'package:orre_mmc_app/features/notifications/screens/notifications_screen.dart';
import 'package:orre_mmc_app/features/engagement/screens/year_in_review_screen.dart';
import 'package:orre_mmc_app/features/engagement/screens/level_up_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login', // Start at login
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 1: Marketplace
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace',
                builder: (context, state) => const MarketplaceScreen(),
              ),
            ],
          ),
          // 2: AI Advisor
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai-advisor',
                builder: (context, state) => const AIAdvisorScreen(),
              ),
            ],
          ),
          // 3: Wallet
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wallet',
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),
          // 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/referrals',
        builder: (context, state) => const ReferralsScreen(),
      ),
      GoRoute(
        path: '/learning',
        builder: (context, state) => const LearningScreen(),
      ),
      GoRoute(
        path: '/governance',
        builder: (context, state) => const GovernanceScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/deposit',
        builder: (context, state) => const DepositScreen(),
      ),
      GoRoute(
        path: '/withdraw',
        builder: (context, state) => const WithdrawScreen(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/kyc-intro',
        builder: (context, state) => const KYCIntroScreen(),
      ),
      GoRoute(
        path: '/digital-key',
        builder: (context, state) => const DigitalKeyScreen(),
      ),
      GoRoute(
        path: '/tax-reports',
        builder: (context, state) => const TaxReportsScreen(),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/sitemap',
        builder: (context, state) => const SitemapScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/property-details',
        builder: (context, state) => const PropertyDetailsScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/property-updates',
        builder: (context, state) => const PropertyUpdatesScreen(),
      ),
      GoRoute(
        path: '/property-tour',
        builder: (context, state) => const PropertyTourScreen(),
      ),
      GoRoute(
        path: '/milestone-rewards',
        builder: (context, state) => const MilestoneRewardsScreen(),
      ),
      GoRoute(
        path: '/referral-milestone',
        builder: (context, state) => const ReferralMilestoneScreen(),
      ),
      GoRoute(
        path: '/article',
        builder: (context, state) => const ArticleScreen(),
      ),
      GoRoute(
        path: '/diversification',
        builder: (context, state) => const DiversificationScreen(),
      ),
      GoRoute(
        path: '/kyc-intro',
        builder: (context, state) => const KYCIntroScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/year-in-review',
        builder: (context, state) => const YearInReviewScreen(),
      ),
      GoRoute(
        path: '/level-up',
        builder: (context, state) => const LevelUpScreen(),
      ),
      GoRoute(
        path: '/comparison',
        builder: (context, state) => const ComparisonScreen(),
      ),
      GoRoute(
        path: '/filters',
        builder: (context, state) => const FiltersScreen(),
      ),
      GoRoute(
        path: '/heat-map',
        builder: (context, state) => const HeatMapScreen(),
      ),
      GoRoute(
        path: '/risk-assessment',
        builder: (context, state) => const RiskAssessmentScreen(),
      ),
      GoRoute(
        path: '/appraisal-history',
        builder: (context, state) => const AppraisalHistoryScreen(),
      ),
      GoRoute(
        path: '/exit-strategy',
        builder: (context, state) => const ExitStrategyScreen(),
      ),
      GoRoute(
        path: '/bank-transfer',
        builder: (context, state) => const BankTransferScreen(),
      ),
      GoRoute(
        path: '/convert',
        builder: (context, state) => const ConvertScreen(),
      ),
      GoRoute(
        path: '/select-asset',
        builder: (context, state) => const SelectAssetScreen(),
      ),
      GoRoute(
        path: '/sell-tokens',
        builder: (context, state) => const SellTokensScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const SuccessScreen(),
      ),
    ],
  );
});
