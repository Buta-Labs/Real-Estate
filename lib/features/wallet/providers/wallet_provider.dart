import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/core/services/toast_service.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';
import 'package:orre_mmc_app/features/auth/repositories/auth_repository.dart';
import 'package:orre_mmc_app/features/auth/repositories/user_repository.dart';

import 'package:orre_mmc_app/features/auth/providers/user_provider.dart';

// We want walletAddressProvider to be initialised from UserProvider but also modifiable locally (if we want to allow switching wallets without saving?)
// Actually, if we want persistence, it should primarily reflect the Source of Truth (Firestore).
// But ConnectWallet updates it.
// Let's make it a computed provider or auto-sync.

final walletAddressProvider = NotifierProvider<WalletAddressNotifier, String?>(
  () {
    return WalletAddressNotifier();
  },
);

class WalletAddressNotifier extends Notifier<String?> {
  @override
  String? build() {
    final userAsync = ref.watch(userProvider);
    return userAsync.value?.walletAddress;
  }

  @override
  set state(String? address) => super.state = address;
}

final walletBalanceProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.watch(blockchainRepositoryProvider);
  // Trigger refresh when address changes
  final address = ref.watch(walletAddressProvider);
  if (address == null) return "0.00";

  return repository.getNativeBalance();
});

final usdcBalanceProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.watch(blockchainRepositoryProvider);
  final address = ref.watch(walletAddressProvider);
  if (address == null) return "0.00";

  // Use the USDC address defined in repository
  try {
    // We need to implement a real getTokenBalance in repository or use a generic one
    // For now, let's assuming repository has a method or we add one.
    // Actually repository.getTokenBalance takes tokenAddress.
    // We'll use the static constant from BlockchainRepository if accessible or hardcode it temporarily/expose it.
    // BlockchainRepository.usdcAddress is static const.
    final balance = await repository.getTokenBalance(
      BlockchainRepository.usdcAddress,
    );
    return balance.toStringAsFixed(2);
  } catch (e) {
    return "0.00";
  }
});

Future<void> connectWallet(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(blockchainRepositoryProvider);
  final result = await repository.connectWallet(context);

  result.when(
    success: (address) async {
      ref.read(walletAddressProvider.notifier).state = address;

      // Persist to Firestore
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        try {
          await ref.read(userRepositoryProvider).updateUser(user.uid, {
            'walletAddress': address,
          });
        } catch (e) {
          debugPrint('Failed to sync wallet to profile: $e');
        }
      }
    },
    failure: (error) {
      debugPrint('Wallet connection failed: ${error.message}');
      if (context.mounted) {
        ToastService().showError(context, error.message);
      }
    },
  );
}
