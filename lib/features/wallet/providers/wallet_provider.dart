import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';

final walletBalanceProvider = FutureProvider.autoDispose<String>((ref) async {
  final repository = ref.watch(blockchainRepositoryProvider);

  // Need to expose web3 client from repository or add a specific method
  // For now, we will add a getNativeBalance method to BlockchainRepository

  // Temporary workaround until we update BlockchainRepository:
  // We will assume the repository has a method to get the balance.
  // Since we can't edit that file instantly in declared dependency,
  // we will structure this provider to use a new method we'll add next.

  return repository.getNativeBalance();
});
