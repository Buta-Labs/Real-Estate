import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_result.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/core/services/toast_service.dart';
import 'package:orre_mmc_app/core/services/contract_service.dart';
import 'package:orre_mmc_app/features/auth/providers/user_provider.dart';
import 'package:orre_mmc_app/shared/widgets/signature_pad.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/investment_repository.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';
import 'package:orre_mmc_app/features/auth/models/user_model.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Property property;
  const CheckoutScreen({super.key, required this.property});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  double _amount = 5000;
  static const double _maxLimit = 24500;
  double get _tokenPrice => widget.property.price;
  static const double _feeRate = 0.005;

  // Instance of repository for rules
  final _invRepo = InvestmentRepository();
  bool _isLoading = false;
  bool _hasShownProfileDialog = false;

  // Contract generation state
  bool _tier2Acknowledged = false;
  Uint8List? _signatureImage;
  double? _liveBalance;

  @override
  void initState() {
    super.initState();
    _fetchLiveBalance();
  }

  Future<void> _fetchLiveBalance() async {
    try {
      final repository = ref.read(blockchainRepositoryProvider);
      const usdcAddress = '0x036CbD53842c5426634e7929541eC2318f3dCF7e';
      final balance = await repository.getTokenBalance(usdcAddress);
      if (mounted) {
        setState(() {
          _liveBalance = balance;
        });
      }
    } catch (e) {
      debugPrint('Error fetching balance: $e');
    }
  }

  // Use dynamic property data
  int get _tierIndex => widget.property.tierIndex;
  String get _contractAddress => widget.property.contractAddress;

  Future<void> _handlePurchase() async {
    final userAsync = ref.read(userProvider);
    final user = userAsync.value;

    if (user == null) {
      _showError('User data not available');
      return;
    }

    // Step 1: Check if Tier 3 foreign investor needs acknowledgment
    if (_tierIndex == 2 &&
        user.country != 'Azerbaijan' &&
        !_tier2Acknowledged) {
      await _showGoldenCheckboxDialog(user);
      return; // Wait for user to acknowledge
    }

    // Step 2: Check if signature is captured
    if (_signatureImage == null) {
      await _showSignatureCaptureDialog(user);
      return; // Wait for signature
    }

    // Step 3: Generate contract and proceed with investment
    await _proceedWithInvestment(user);
  }

  /// Step 1: Show Golden Checkbox for Tier 2 foreign investors
  Future<void> _showGoldenCheckboxDialog(dynamic user) async {
    bool acknowledged = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C2333),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.gavel, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tier 3 Stay Rights Disclosure',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IMPORTANT LEGAL NOTICE',
                style: TextStyle(
                  color: Color(0xFF0BDA5E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'As a Tier 3 investor, you will receive stay rights at the property. However, you must understand and acknowledge the following:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: acknowledged,
                onChanged: (value) {
                  setDialogState(() {
                    acknowledged = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                title: const Text(
                  'I understand that Tier 3 stay rights are a revocable personal license managed by ORRE LLC and do not constitute a timeshare, tenancy, or property right.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: acknowledged
                  ? () {
                      setState(() {
                        _tier2Acknowledged = true;
                      });
                      context.pop();

                      // Save acknowledgment timestamp to Firestore
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({
                            'tier2AcknowledgmentTime':
                                FieldValue.serverTimestamp(),
                          });

                      // Proceed to next step
                      _handlePurchase();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Show signature capture dialog
  Future<void> _showSignatureCaptureDialog(dynamic user) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Sign Investment Agreement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign below to confirm your agreement to the investment terms and conditions.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SignaturePad(
              onSignatureCaptured: (signature) {
                setState(() {
                  _signatureImage = signature;
                });
                Navigator.of(context).pop();
                // Proceed to contract generation
                _handlePurchase();
              },
              onClear: () {
                // Signature cleared
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Step 3: Generate contract and proceed with blockchain investment
  Future<void> _proceedWithInvestment(dynamic user) async {
    setState(() => _isLoading = true);

    try {
      // Generate legal contract PDF
      ToastService().showInfo(context, 'Generating legal contract...');

      final contractService = ContractService();
      final contractResult = await contractService.generateInvestmentContract(
        userId: user.uid,
        propertyId: widget.property.id,
        investmentAmount: _amount,
        signatureImage: _signatureImage!,
        userData: {
          'fullName': user.fullLegalName ?? user.displayName ?? 'Unknown',
          'idNumber': user.idNumber ?? 'N/A',
          'address': user.address ?? 'N/A',
          'country': user.country ?? 'Unknown',
        },
        propertyData: {
          'title': widget.property.title,
          'contractAddress': _contractAddress,
          'tierIndex': _tierIndex,
        },
        transactionHash: 'PENDING', // Will be updated after blockchain tx
      );

      if (!mounted) return;
      ToastService().showSuccess(context, 'Contract generated successfully!');
      ToastService().showInfo(
        context,
        'Hash: ${contractResult.pdfHash.substring(0, 10)}...',
      );

      // Connect wallet
      final repository = ref.read(blockchainRepositoryProvider);
      final balance = await repository.getNativeBalance();
      if (balance == "0.00") {
        if (!mounted) return;
        final result = await repository.connectWallet(context);
        if (result is Failure) {
          _showError('Please connect your wallet first.');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Perform blockchain transaction with PDF hash
      final result = await repository.purchaseToken(
        _contractAddress,
        _amount,
        legalDocHash: contractResult.pdfHash,
        onStatusChanged: (status) {
          ToastService().showInfo(context, status);
        },
      );

      if (result is Success) {
        if (mounted) {
          ToastService().showSuccess(
            context,
            'Contract uploaded: ${contractResult.storageUrl}',
          );
          context.push('/success');
        }
      } else if (result is Failure) {
        _showError(
          'Transaction failed: ${(result as Failure).failure.message}',
        );
      }
    } catch (e) {
      _showError('Contract generation failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ToastService().showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    // Check if user has completed required profile fields
    final userAsync = ref.watch(userProvider);

    final tokenCount = (_amount / _tokenPrice).floor();
    final processingFee = _amount * _feeRate;
    final total = _amount + processingFee;

    // Show profile completion dialog if user data is loaded but incomplete
    userAsync.whenData((user) {
      if (user != null && !user.hasCompletedContractProfile()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showCompleteProfileDialog(context, user);
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Invest',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildAssetContextCard(),
                  const SizedBox(height: 32),
                  _buildAmountInput(tokenCount),
                  const SizedBox(height: 48),
                  _buildSlider(_maxLimit),
                  const SizedBox(height: 24),
                  _buildWalletBalance(_liveBalance ?? _maxLimit),
                ],
              ),
            ),
          ),
          _buildSummaryPanel(processingFee, total),
        ],
      ),
    );
  }

  Widget _buildAssetContextCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.property.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Fractional Ownership • ${widget.property.yieldRate}% Yield',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAmountInput(int tokenCount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              '\$',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            IntrinsicWidth(
              child: TextFormField(
                initialValue: _amount.toInt().toString(),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  final val = double.tryParse(value);
                  if (val != null) {
                    setState(() => _amount = val);
                  }
                },
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.token, color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Text(
                '≈ ${tokenCount.toString()} ORRE Tokens',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(double max) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: const Color(0xFF1C2333),
            thumbColor: Colors.white,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _amount.clamp(
              _invRepo.getMinimumInvestment(_tierIndex),
              max,
            ),
            min: _invRepo.getMinimumInvestment(_tierIndex).toDouble(),
            max: max,
            onChanged: (value) => setState(() => _amount = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_invRepo.getMinimumInvestment(_tierIndex).toInt()}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                '\$${max.toInt()}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletBalance(double max) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Balance: \$${_liveBalance?.toStringAsFixed(2) ?? max.toStringAsFixed(2)} USDC',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        TextButton(
          onPressed: () => setState(() => _amount = _liveBalance ?? max),
          child: const Text(
            'Use Max',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryPanel(double processingFee, double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Investment', style: TextStyle(color: Colors.grey)),
              Text(
                '\$${_amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    'Processing Fee (0.5%)',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.help_outline, color: Colors.grey, size: 14),
                ],
              ),
              Text(
                '\$${processingFee.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.backgroundDark,
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Confirm Investment'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show dialog forcing user to complete profile before investing
  void _showCompleteProfileDialog(BuildContext context, UserModel user) {
    // Prevent multiple dialogs
    if (_hasShownProfileDialog) return;
    _hasShownProfileDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false, // Cannot dismiss without action
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Complete Your Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To proceed with investments, you must complete the following required fields in your profile:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildRequiredField(
              'Full Legal Name',
              isComplete:
                  user.fullLegalName != null && user.fullLegalName!.isNotEmpty,
            ),
            _buildRequiredField(
              'Country of Residence',
              isComplete: user.country != null && user.country!.isNotEmpty,
            ),
            _buildRequiredField(
              'ID Number',
              isComplete: user.idNumber != null && user.idNumber!.isNotEmpty,
            ),
            const SizedBox(height: 16),
            const Text(
              'These details are required for generating legally binding investment contracts.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              context.pop(); // Go back from checkout
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              Future.microtask(() {
                if (context.mounted) {
                  context.go('/profile');
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredField(String label, {required bool isComplete}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle_outline : Icons.circle_outlined,
            color: isComplete ? AppColors.primary : Colors.white24,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isComplete ? Colors.white : Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
