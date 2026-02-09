import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/features/auth/screens/login_screen.dart';
import 'package:orre_mmc_app/features/auth/screens/phone_login_screen.dart';
import 'package:orre_mmc_app/features/auth/screens/complete_profile_screen.dart';
import 'package:orre_mmc_app/features/auth/screens/mfa_enrollment_screen.dart';
import 'package:orre_mmc_app/features/auth/screens/mfa_verification_screen.dart';
import 'package:orre_mmc_app/features/auth/screens/signup_screen.dart';
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
import 'package:orre_mmc_app/features/marketplace/models/project_model.dart';
import 'package:orre_mmc_app/features/marketplace/screens/project_details_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/checkout_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/property_updates_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/property_tour_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/comparison_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/filters_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/heat_map_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/risk_assessment_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/appraisal_history_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/exit_strategy_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/offering_memorandum_screen.dart';
import 'package:orre_mmc_app/features/marketplace/screens/map_view_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/bank_transfer_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/convert_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/select_asset_screen.dart';
import 'package:orre_mmc_app/features/wallet/screens/sell_tokens_screen.dart';
import 'package:orre_mmc_app/shared/screens/success_screen.dart';
import 'package:orre_mmc_app/features/referrals/screens/milestone_rewards_screen.dart';
import 'package:orre_mmc_app/features/referrals/screens/referral_milestone_screen.dart';
import 'package:orre_mmc_app/features/learning/screens/article_screen.dart';
import 'package:orre_mmc_app/features/portfolio/screens/diversification_screen.dart';
import 'package:orre_mmc_app/features/onboarding/screens/kyc_intro_screen.dart';
import 'package:orre_mmc_app/features/onboarding/screens/scanner_screen.dart';
import 'package:orre_mmc_app/features/profile/screens/edit_profile_screen.dart';
import 'package:orre_mmc_app/shared/screens/loading_screen.dart';
import 'package:orre_mmc_app/features/notifications/screens/notifications_screen.dart';
import 'package:orre_mmc_app/features/engagement/screens/year_in_review_screen.dart';
import 'package:orre_mmc_app/features/engagement/screens/level_up_screen.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Tracks if MFA is enrolled. null = loading, true = enrolled, false = not enrolled.
final mfaProvider = NotifierProvider<MfaNotifier, bool?>(() {
  return MfaNotifier();
});

class MfaNotifier extends Notifier<bool?> {
  @override
  bool? build() {
    final authRepo = ref.read(authRepositoryProvider);

    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      final previousUser = previous?.value;

      if (user == null) {
        state = false;
      } else {
        // Only reset to null if the user has changed to prevent flashing
        if (previousUser?.uid != user.uid) {
          state = null;
        }

        // Trigger async check
        unawaited(() async {
          try {
            final dynamic mf = (user as dynamic).multiFactor;
            // Try async getEnrolledFactors first
            final List<dynamic> factors = await mf.getEnrolledFactors();
            if (state == null) state = factors.isNotEmpty;
          } catch (e) {
            // Fallback to sync check using captured repo
            state = authRepo.hasMfaEnrolled(user);
          }
        }());
      }
    });

    return null;
  }

  void setVerified(bool isVerified) {
    state = isVerified;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login', // Start at login
    refreshListenable: GoRouterRefreshStream(
      ref.read(authRepositoryProvider).authStateChanges(),
    ),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
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
        pageBuilder: (context, state) => MaterialPage(
          key: const ValueKey('security-settings'),
          child: const SecuritySettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/kyc-intro',
        builder: (context, state) => const KYCIntroScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/kyc-verification',
        builder: (context, state) => const KYCIntroScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
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
        builder: (context, state) {
          final property = state.extra as Property;
          return PropertyDetailsScreen(property: property);
        },
      ),
      GoRoute(
        path: '/project-details/:id',
        builder: (context, state) {
          final project = state.extra as Project;
          return ProjectDetailsScreen(project: project);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final property = state.extra as Property;
          return CheckoutScreen(property: property);
        },
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
        builder: (context, state) {
          final property = state.extra as Property;
          return RiskAssessmentScreen(property: property);
        },
      ),
      GoRoute(
        path: '/appraisal-history',
        builder: (context, state) {
          final property = state.extra as Property;
          return AppraisalHistoryScreen(property: property);
        },
      ),
      GoRoute(
        path: '/exit-strategy',
        builder: (context, state) {
          final property = state.extra as Property;
          return ExitStrategyScreen(property: property);
        },
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
        path: '/success',
        builder: (context, state) => const SuccessScreen(),
      ),
      GoRoute(
        path: '/map-view',
        builder: (context, state) => const MapViewScreen(),
      ),
      GoRoute(
        path: '/offering-memorandum',
        builder: (context, state) {
          final tierIndex = state.extra as int;
          return OfferingMemorandumScreen(tierIndex: tierIndex);
        },
      ),
      GoRoute(
        path: '/mfa-enrollment',
        pageBuilder: (context, state) => MaterialPage(
          key: const ValueKey('mfa-enrollment'),
          child: const MfaEnrollmentScreen(),
        ),
      ),
      GoRoute(
        path: '/mfa-verification',
        pageBuilder: (context, state) => MaterialPage(
          key: const ValueKey('mfa-verification'),
          child: MfaVerificationScreen(
            resolver: state.extra as MultiFactorResolver?,
          ),
        ),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider);
      final hasMfaEnrolledValue = ref.watch(mfaProvider);

      if (authState.isLoading) return '/loading';

      final user = authState.value;

      // 0. Essential: Allow Public Routes
      final isVerifyMfa = state.matchedLocation == '/mfa-verification';
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isPhoneLogin = state.matchedLocation == '/phone-login';
      final isMfaEnrollment = state.matchedLocation == '/mfa-enrollment';
      final isCompleteProfile = state.matchedLocation == '/complete-profile';

      if (user == null) {
        // IMPORTANT: Allow /mfa-verification even if user is null
        // (Firebase Auth considers user null until resolving MFA)
        if (isVerifyMfa || isLoggingIn || isSigningUp || isPhoneLogin) {
          return null;
        }
        return '/login';
      }

      // 1. If MFA status is still loading (null), go to loading screen
      if (hasMfaEnrolledValue == null) return '/loading';

      final hasMfa = hasMfaEnrolledValue == true;
      final hasPhoneNumber =
          user.phoneNumber != null && user.phoneNumber!.isNotEmpty;
      final sessionMfaVerified = ref.watch(mfaVerifiedProvider);

      // 2. Enforce Mandatory Profile Completion (Email & Name) - ONLY FOR WALLET/ANONYMOUS
      // For Google/Email users, we skip this gate as they provide data during the initial flow.
      final isMissingProfile =
          user.email == null ||
          user.email!.isEmpty ||
          user.displayName == null ||
          user.displayName!.isEmpty;

      if (user.isAnonymous && isMissingProfile) {
        if (!isCompleteProfile) {
          return '/complete-profile';
        }
        return null;
      }

      // If they have a phone number but haven't verified it in THIS session,
      // they must go to verification.
      if (hasPhoneNumber && !sessionMfaVerified) {
        if (!isVerifyMfa) {
          return '/mfa-verification';
        }
        return null;
      }

      // If they don't have MFA or a phone number at all, they must enroll.
      if (!hasMfa && !hasPhoneNumber) {
        if (!isMfaEnrollment && !isCompleteProfile) {
          return '/mfa-enrollment';
        }
        return null;
      }

      // 3. If they are trying to access PURE auth pages while logged in (and fully verified), send to dashboard
      // We EXCLUDE /mfa-enrollment and /mfa-verification here to allow manual pushes from settings.
      if (isLoggingIn || isSigningUp || isPhoneLogin) {
        return '/dashboard';
      }

      return null;
    },
  );
});

/// A [Listenable] that notifies listeners when a [Stream] emits a value.
/// Used to bridge [StreamProvider] to [GoRouter.refreshListenable].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
