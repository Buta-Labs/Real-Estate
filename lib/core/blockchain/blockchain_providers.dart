import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'blockchain_repository.dart';

final blockchainRepositoryProvider = Provider<BlockchainRepository>((ref) {
  return BlockchainRepository();
});

final walletAddressProvider = StateProvider<String?>((ref) => null);

final networkIdProvider = StateProvider<int>((ref) => 137); // Default Polygon
