import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'blockchain_repository.dart';

final blockchainRepositoryProvider = Provider<BlockchainRepository>((ref) {
  return BlockchainRepository();
});

final walletAddressProvider = NotifierProvider<WalletAddressNotifier, String?>(
  () {
    return WalletAddressNotifier();
  },
);

class WalletAddressNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? address) => state = address;
}

final networkIdProvider = NotifierProvider<NetworkIdNotifier, int>(() {
  return NetworkIdNotifier();
});

class NetworkIdNotifier extends Notifier<int> {
  @override
  int build() => 137; // Default Polygon

  void update(int id) => state = id;
}
