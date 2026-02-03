import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/features/kyc/repositories/kyc_repository.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _isScanning = false;
  bool _hasPermission = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _hasPermission = true);
    });
  }

  Future<void> _handleCapture() async {
    if (!_hasPermission || _isScanning) return;

    // 1. Pick Image
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() => _isScanning = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // 2. Upload to Firebase Storage
      final kycRepo = ref.read(kycRepositoryProvider);
      final downloadUrl = await kycRepo.uploadDocument(
        userId: user.uid,
        file: File(image.path),
        documentType: 'id_card', // For MVP, assuming ID card
      );

      // 3. Submit Application
      await kycRepo.submitApplication(
        userId: user.uid,
        data: {'documentUrl': downloadUrl, 'documentType': 'id_card'},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully!')),
        );
        // Navigate to dashboard or success screen
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Feed (Mock)
          if (_hasPermission)
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAI6y-veCO3myE6T6JW6e5n_Pn-LDrxDRwBbFSIsR426r47OF67vSq9lqiJrnkbKNKYuHMvnmVWuIJDd66NdGGO-DYzhVx-MRNEdnYUSeDXz7TKRfax_9DdM_Em7McVexKceur0zldWWOdYdnifLb9obSooyldqTjC-EKNKZuSFBdZQQ3G5nnbdm6xrD74R-W23_FQmpDL6LjARkn0_kJp55hqKeR5ORyTNtPYFE2lWWQLOTd_sCEJHGMALQnZTHVxAlo62hbpt1A',
              fit: BoxFit.cover,
              color: Colors.white.withValues(alpha: 0.8),
              colorBlendMode: BlendMode.modulate,
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // Overlays
          Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.width * 0.85 * (4 / 3),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isScanning
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        // Corners
                        _buildCorner(true, true),
                        _buildCorner(true, false),
                        _buildCorner(false, true),
                        _buildCorner(false, false),

                        // Scan Line
                        if (!_isScanning && _hasPermission)
                          const Center(
                            child: Divider(
                              color: AppColors.primary,
                              thickness: 2,
                            ),
                          ), // In real app, add animation

                        if (_isScanning)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'VERIFYING DOCUMENT...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 160,
                decoration: BoxDecoration(
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
            ],
          ),

          // Message
          Positioned(
            left: 0,
            right: 0,
            bottom: 180,
            child: Text(
              _isScanning ? 'Hold still...' : 'Align your ID within the frame',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
          ),

          // Controls
          Positioned(
            top: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.close, onPressed: () => context.pop()),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.1),
                  child: const Text(
                    'Identity Verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                _buildCircleButton(Icons.flash_on, onPressed: () {}),
              ],
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _handleCapture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    const double size = 32;
    const double thickness = 4;
    return Positioned(
      top: isTop ? -2 : null,
      bottom: !isTop ? -2 : null,
      left: isLeft ? -2 : null,
      right: !isLeft ? -2 : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: AppColors.primary, width: thickness)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: AppColors.primary, width: thickness)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: AppColors.primary, width: thickness)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: AppColors.primary, width: thickness)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(24) : Radius.zero,
            topRight: isTop && !isLeft
                ? const Radius.circular(24)
                : Radius.zero,
            bottomLeft: !isTop && isLeft
                ? const Radius.circular(24)
                : Radius.zero,
            bottomRight: !isTop && !isLeft
                ? const Radius.circular(24)
                : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
