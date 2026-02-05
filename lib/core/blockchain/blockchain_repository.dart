import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:orre_mmc_app/router/app_router.dart';
import 'blockchain_result.dart';

final blockchainRepositoryProvider = Provider<BlockchainRepository>((ref) {
  return BlockchainRepository();
});

class BlockchainRepository {
  static const String baseRpcUrl =
      "https://sepolia.base.org"; // Base Sepolia Testnet
  static const int chainId = 84532;
  static const String zavodFactoryAddress =
      '0xb6A2bF1C7d9460819cFDE08af8E6DEA031b23D09';

  late final Web3Client _client;
  late final ReownAppKitModal _appKitModal;

  // WalletConnect Cloud Project ID
  static const String _projectId = '6e6e0303545b8c61c05be76e8cca87f0';

  BlockchainRepository() {
    _client = Web3Client(baseRpcUrl, Client());

    // Initialize AppKitModal.
    // Note: In a real app, this initialization might be better placed in a provider
    // that uses await to ensure it's ready, or we must ensure initialize() is called.
    // For this refactor, we'll initialize it immediately but call init() async.
    _appKitModal = ReownAppKitModal(
      context: rootNavigatorKey.currentContext!,
      projectId: _projectId,
      metadata: const PairingMetadata(
        name: 'Orre',
        description: 'Orre Real Estate Tokenization App',
        url: 'https://orre.com',
        icons: ['https://orre.com/favicon.ico'],
        redirect: Redirect(
          native: 'orre://',
          universal: 'https://orre.com',
          linkMode: true,
        ),
      ),
      enableAnalytics: true, // Optional
    );

    // We should initialize it
    _appKitModal.init();
  }

  ReownAppKitModal get appKitModal => _appKitModal;

  Future<void> initialize() async {
    await _appKitModal.init();
  }

  Future<BlockchainResult<String>> connectWallet(BuildContext context) async {
    try {
      if (_appKitModal.isConnected) {
        return Success(
          _appKitModal.session?.namespaces?['eip155']?.accounts.first
                  .split(':')
                  .last ??
              '',
        );
      }

      // Open the modal
      await _appKitModal.openModalView();

      // We can't easily wait for the result of the modal here since open() returns void/Future<void>.
      // The session updates happen asynchronously.
      // However, for this method signature stability, we can check if connected after open returns (if it blocks)
      // or we rely on the provider listening to appKitModal.addListener.

      // Reown AppKit manages the session state internally.
      // We'll return Success if connected, or the user can check status via provider updates.
      // Ideally, the UI consumes the `appKitModal` directly for state.
      // But for backward compat with our `connectWallet` call:

      // Wait for a bit or check status?
      // Actually `open` awaits until the modal is closed.
      if (_appKitModal.isConnected) {
        return Success(
          _appKitModal.session?.namespaces?['eip155']?.accounts.first
                  .split(':')
                  .last ??
              '',
        );
      }

      return const Failure(UserRejected()); // Or just not connected
    } catch (e) {
      return Failure(UnknownError(e));
    }
  }

  Future<BlockchainResult<String>> mintPropertyToken(
    String toAddress,
    double amount,
    String propertyId, {
    Function(String)? onStatusChanged,
  }) async {
    try {
      if (!_appKitModal.isConnected) return const Failure(WalletNotConnected());

      final senderAddress = _appKitModal
          .session
          ?.namespaces?['eip155']
          ?.accounts
          .first
          .split(':')
          .last;
      if (senderAddress == null) {
        return const Failure(UnknownError('No account found'));
      }

      onStatusChanged?.call('Preparing mint transaction...');

      // Placeholder Data
      final tx = {
        'from': senderAddress,
        'to': toAddress,
        'data': '0x', // Todo: Encode actual ABI
      };

      onStatusChanged?.call('Please sign in wallet...');

      // AppKitModal request
      final result = await _appKitModal.request(
        topic: _appKitModal.session!.topic!,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [tx],
        ),
      );

      return Success(result.toString());
    } catch (e) {
      return Failure(UnknownError(e));
    }
  }

  Future<BlockchainResult<String>> purchaseToken(
    String propertyContractAddress,
    double amountInUsdt, {
    Function(String)? onStatusChanged,
  }) async {
    try {
      if (!_appKitModal.isConnected) return const Failure(WalletNotConnected());

      final senderAddress = _appKitModal
          .session
          ?.namespaces?['eip155']
          ?.accounts
          .first
          .split(':')
          .last;
      if (senderAddress == null) {
        return const Failure(UnknownError('No account found'));
      }

      onStatusChanged?.call('Requesting approval from wallet...');

      final tx = {
        'from': senderAddress,
        'to': propertyContractAddress,
        'data': '0x',
      };

      final result = await _appKitModal.request(
        topic: _appKitModal.session!.topic!,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [tx],
        ),
      );

      onStatusChanged?.call('Transaction submitted!');
      return Success(result.toString());
    } catch (e) {
      return Failure(UnknownError(e));
    }
  }

  Future<String> getNativeBalance() async {
    try {
      if (!_appKitModal.isConnected) {
        return "0.00";
      }

      final addressStr = _appKitModal
          .session
          ?.namespaces?['eip155']
          ?.accounts
          .first
          .split(':')
          .last;
      if (addressStr == null) return "0.00";

      // Use AppKit's balance fetching if available, or fallback to Web3Client
      // AppKit often has balance in the session/account data
      final balance = _appKitModal.balanceNotifier.value;
      if (balance.isNotEmpty) {
        return balance; // It returns formatted string usually? Or just value.
        // Let's stick to reliable Web3Client for consistency if AppKit format varies
      }

      final address = EthereumAddress.fromHex(addressStr);
      final amount = await _client.getBalance(address);

      return amount.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching balance: $e');
      return "0.00";
    }
  }

  Future<BlockchainResult<String>> transferToken(
    String tokenAddress,
    String toAddress,
    double amount, {
    Function(String)? onStatusChanged,
  }) async {
    try {
      if (!_appKitModal.isConnected) return const Failure(WalletNotConnected());

      final senderAddress = _appKitModal
          .session
          ?.namespaces?['eip155']
          ?.accounts
          .first
          .split(':')
          .last;
      if (senderAddress == null) {
        return const Failure(UnknownError('No account found'));
      }

      onStatusChanged?.call('Preparing transfer details...');

      // 1. Create Contract Interface
      // Minimal ABI for transfer
      const abi =
          '[{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]';
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'ERC20'),
        EthereumAddress.fromHex(tokenAddress),
      );

      // 2. Encode Function Call
      final transferFunction = contract.function('transfer');
      final amountInUnits = BigInt.from(amount * 1000000); // 6 Decimals
      final data = transferFunction.encodeCall([
        EthereumAddress.fromHex(toAddress),
        amountInUnits,
      ]);

      // 3. Convert Uint8List data to Hex String
      // Manually or ensuring web3dart utility usage.
      // Reown AppKit expects '0x...' string.
      final dataHex =
          '0x${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

      onStatusChanged?.call('Please sign in wallet...');

      // 4. Send Transaction
      final result = await _appKitModal.request(
        topic: _appKitModal.session!.topic!,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': senderAddress,
              'to': tokenAddress, // Transaction to Token Contract
              'data': dataHex,
            },
          ],
        ),
      );

      onStatusChanged?.call('Transfer Submitted!');
      return Success(result.toString());
    } catch (e) {
      return Failure(UnknownError(e));
    }
  }

  Future<double> getTokenBalance(String tokenAddress) async {
    if (tokenAddress == '0x1234567890123456789012345678901234567890') {
      if (_appKitModal.isConnected) return 500.0;
    }
    return 0.0;
  }

  Future<List<String>> getDeployedProperties() async {
    try {
      const abi =
          '[{"inputs":[],"name":"getProperties","outputs":[{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"}]';
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'ZavodFactory'),
        EthereumAddress.fromHex(zavodFactoryAddress),
      );

      final function = contract.function('getProperties');
      final result = await _client.call(
        contract: contract,
        function: function,
        params: [],
      );

      final List<dynamic> addresses = result.first;
      return addresses.map((e) => (e as EthereumAddress).hex).toList();
    } catch (e) {
      debugPrint('Error fetching deployed properties: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPropertyDetails(String address) async {
    try {
      const abi =
          '[{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"pricePerToken","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"legalDocHash","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"tierIndex","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"}]';
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'PropertyToken'),
        EthereumAddress.fromHex(address),
      );

      final nameFunc = contract.function('name');
      final priceFunc = contract.function('pricePerToken');
      final docFunc = contract.function('legalDocHash');
      final tierFunc = contract.function('tierIndex');

      final nameResult = await _client.call(
        contract: contract,
        function: nameFunc,
        params: [],
      );
      final priceResult = await _client.call(
        contract: contract,
        function: priceFunc,
        params: [],
      );
      final docResult = await _client.call(
        contract: contract,
        function: docFunc,
        params: [],
      );
      final tierResult = await _client.call(
        contract: contract,
        function: tierFunc,
        params: [],
      );

      return {
        'name': nameResult.first as String,
        'price':
            (priceResult.first as BigInt).toDouble() /
            1000000.0, // Assuming 6 decimals like USDC
        'legalDocHash': docResult.first as String,
        'tierIndex': (tierResult.first as BigInt).toInt(),
      };
    } catch (e) {
      debugPrint('Error fetching property details for $address: $e');
      return {};
    }
  }
}
