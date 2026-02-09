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

  try {
    final balance = await repository.getTokenBalance(
      BlockchainRepository.usdcAddress,
    );
    return balance.toStringAsFixed(2);
  } catch (e) {
    return "0.00";
  }
});

final usdtBalanceProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.watch(blockchainRepositoryProvider);
  final address = ref.watch(walletAddressProvider);
  if (address == null) return "0.00";

  try {
    final balance = await repository.getTokenBalance(
      BlockchainRepository.usdtAddress,
    );
    return balance.toStringAsFixed(2);
  } catch (e) {
    return "0.00";
  }
});

/// A provider that switches balance based on the UI selection (USDT/USDC)
/// Importing the UI provider here might cause circularity, so we'll look it up via ref.watch if we move it or define a common one.
/// For now, since WalletCurrencyNotifier is in wallet_screen.dart, we should probably move it to a shared place or this provider file.
final activeTokenBalanceProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  // We need to watch the currency selection.
  // Since WalletCurrencyNotifier is currently in wallet_screen.dart, let's assume we pass the ref or move the notifier.
  // I will move WalletCurrencyNotifier to this file for better architectural layering.
  final currency = ref.watch(walletCurrencyProvider);
  if (currency == 'USDC') {
    return ref.watch(usdcBalanceProvider.future);
  } else {
    return ref.watch(usdtBalanceProvider.future);
  }
});

class WalletCurrencyNotifier extends Notifier<String> {
  @override
  String build() => 'USDT';

  void setCurrency(String currency) {
    state = currency;
  }
}

final walletCurrencyProvider = NotifierProvider<WalletCurrencyNotifier, String>(
  WalletCurrencyNotifier.new,
);

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
