import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';

class KYCIntroScreen extends StatelessWidget {
  const KYCIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: _buildMainContent(),
                  ),
                ),
                _buildBottomAction(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.transparent),
          ),
          const Expanded(
            child: Text(
              'Identity Verification',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance spacing
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      color: Colors.white.withOpacity(0.05),
      child: Column(
        children: [
          const Text(
            'Verify your Identity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'To comply with financial regulations and secure your account, we need to verify who you are. It only takes 2 minutes.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _buildTimelineStep(
          icon: Icons.person,
          title: 'Personal Details',
          subtitle: 'Name, Address, DOB',
          state: _StepState.active,
        ),
        _buildTimelineStep(
          icon: Icons.badge,
          title: 'ID Document',
          subtitle: 'Passport or Driver\'s License',
          state: _StepState.upcoming,
        ),
        _buildTimelineStep(
          icon: Icons.face,
          title: 'Selfie Check',
          subtitle: 'Biometric face match',
          state: _StepState.upcoming,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required _StepState state,
    bool isLast = false,
  }) {
    final color = state == _StepState.active
        ? AppColors.primary
        : Colors.grey[400];
    final bgColor = state == _StepState.active
        ? AppColors.primary.withOpacity(0.2)
        : Colors.white.withOpacity(0.05);
    final borderColor = state == _StepState.active
        ? AppColors.primary.withOpacity(0.2)
        : Colors.white.withOpacity(0.1);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                  boxShadow: state == _StepState.active
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: state == _StepState.upcoming
                          ? Colors.grey[300]
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDark,
            AppColors.backgroundDark.withOpacity(0),
          ],
        ),
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.push('/scanner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: AppColors.primary.withOpacity(0.4),
              elevation: 4,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Start Verification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                'Bank-grade encryption. Data privacy guaranteed.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _StepState { active, upcoming }
