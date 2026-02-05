import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/auth/providers/user_provider.dart';
import 'package:orre_mmc_app/features/auth/repositories/user_repository.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _fullLegalNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _addressController;
  String? _selectedCountry;
  bool _isLoading = false;

  // Standard country list with Azerbaijan first
  static const List<String> _countries = [
    'Azerbaijan',
    'Turkey',
    'United States',
    'United Kingdom',
    'Russia',
    'Georgia',
    'Kazakhstan',
    'United Arab Emirates',
    'Germany',
    'France',
    'China',
    'India',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).valueOrNull;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _fullLegalNameController = TextEditingController(
      text: user?.fullLegalName ?? '',
    );
    _idNumberController = TextEditingController(text: user?.idNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _selectedCountry = user?.country;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullLegalNameController.dispose();
    _idNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final user = ref.read(userProvider).valueOrNull;
    if (user == null) return;

    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your display name');
      return;
    }

    if (_fullLegalNameController.text.trim().isEmpty) {
      _showError('Please enter your full legal name');
      return;
    }

    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      _showError('Please select your country of residence');
      return;
    }

    if (_idNumberController.text.trim().isEmpty) {
      _showError('Please enter your ID/Passport number');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showError('Please enter your residential address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(userRepositoryProvider).updateUser(user.uid, {
        'displayName': _nameController.text.trim(),
        'fullLegalName': _fullLegalNameController.text.trim(),
        'country': _selectedCountry,
        'idNumber': _idNumberController.text.trim(),
        'address': _addressController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Complete Profile',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compliance Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Required for investment contracts and legal compliance',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Display Name
            _buildInputField(
              'DISPLAY NAME',
              Icons.person_outline,
              _nameController,
              'How others see you in the app',
            ),
            const SizedBox(height: 20),

            // Full Legal Name
            _buildInputField(
              'FULL LEGAL NAME *',
              Icons.badge_outlined,
              _fullLegalNameController,
              'As it appears on your ID/Passport',
            ),
            const SizedBox(height: 20),

            // Country Selector
            _buildCountrySelector(),
            const SizedBox(height: 20),

            // ID Number
            _buildInputField(
              'ID/PASSPORT NUMBER *',
              Icons.credit_card,
              _idNumberController,
              'Your government-issued ID number',
            ),
            const SizedBox(height: 20),

            // Address
            _buildInputField(
              'RESIDENTIAL ADDRESS *',
              Icons.home_outlined,
              _addressController,
              'Your current place of residence',
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        'Save & Continue',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                'COUNTRY OF RESIDENCE *',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.flag, size: 14, color: AppColors.primary),
            ],
          ),
        ),
        GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCountry,
            dropdownColor: AppColors.card,
            decoration: InputDecoration(
              icon: Icon(Icons.public, color: Colors.grey[400], size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              hintText: 'Select your country',
              hintStyle: TextStyle(color: Colors.grey[600]),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            items: _countries.map((country) {
              return DropdownMenuItem(value: country, child: Text(country));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 6),
          child: Text(
            'Required for legal compliance and contract generation',
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
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
            style: const TextStyle(color: Colors.white),
            maxLines: maxLines,
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.grey[400], size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
