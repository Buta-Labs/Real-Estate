import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orre_mmc_app/features/auth/controllers/auth_controller.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSignup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: _nameController.text.trim(),
          imageFile: _imageFile,
        );

    if (mounted && ref.read(authControllerProvider).hasError == false) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background (reusing Login Screen style)
          Positioned.fill(
            child: Container(
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
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create Account',
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profile Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                            child: _imageFile == null
                                ? Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 32,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.backgroundDark,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildInputField(
                      'FULL NAME',
                      Icons.person_outline,
                      _nameController,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'EMAIL',
                      Icons.mail_outline,
                      _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'PASSWORD',
                      Icons.lock_outline,
                      _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'CONFIRM PASSWORD',
                      Icons.lock_outline,
                      _confirmPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Sign Up',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Already have an account? Sign In',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
        ),
        GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.grey[400], size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
