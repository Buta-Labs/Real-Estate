import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'blockchain_result.dart';

final blockchainRepositoryProvider = Provider<BlockchainRepository>((ref) {
  return BlockchainRepository();
});

class BlockchainRepository {
  static const String polygonRpcUrl = "https://polygon-rpc.com"; // Public Node
  static const int chainId = 137;

  late final Web3Client _client;
  late final Web3App _web3App;
  SessionData? _sessionData;

  BlockchainRepository() {
    _client = Web3Client(polygonRpcUrl, Client());
    _initializeWalletConnect();
  }

  // TODO: Replace with your actual Project ID from WalletConnect Cloud
  static const String _projectId = '1051ea178fd7ba828e8b427d98d117c3';

  Future<void> _initializeWalletConnect() async {
    _web3App = await Web3App.createInstance(
      projectId: _projectId,
      metadata: const PairingMetadata(
        name: 'Orre MMC',
        description: 'Orre Real Estate Tokenization App',
        url: 'https://orre.com',
        icons: ['https://orre.com/favicon.ico'],
      ),
    );
  }

  Future<BlockchainResult<String>> connectWallet({
    Function(Uri)? onDisplayUri,
  }) async {
    try {
      if (_sessionData != null) {
        return Success(
          _sessionData!.namespaces['eip155']?.accounts.first.split(':').last ??
              '',
        );
      }

      ConnectResponse resp = await _web3App.connect(
        requiredNamespaces: {
          'eip155': const RequiredNamespace(
            chains: ['eip155:137'], // Polygon
            methods: ['eth_sendTransaction', 'personal_sign'],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      );

      if (resp.uri != null) {
        onDisplayUri?.call(resp.uri!);
      }

      // Wait for session proposal to be approved
      _sessionData = await resp.session.future;

      if (_sessionData != null) {
        final address = _sessionData!.namespaces['eip155']?.accounts.first
            .split(':')
            .last;
        return Success(address ?? '');
      }

      return const Failure(UserRejected());
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
      if (_sessionData == null) return const Failure(WalletNotConnected());

      // Use _client to silence warning and show intent
      // ignore: unused_local_variable
      final chainId = await _client.getChainId();

      onStatusChanged?.call('Preparing transaction...');
      // 1. Get nonce
      // 2. Encode ABI for mint(to, amount, propertyId)
      // 3. Sign transaction (Admin Private Key required - placeholder)

      onStatusChanged?.call('Sending transaction...');
      // final txHash = await _client.sendTransaction(...);

      await Future.delayed(const Duration(seconds: 2)); // Mock delay

      onStatusChanged?.call('Transaction successful!');
      return const Success("0xMOCK_TX_HASH_MINT");
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
      if (_sessionData == null) return const Failure(WalletNotConnected());

      onStatusChanged?.call('Approving USDT...');
      // 1. Call USDT Contract -> approve(propertyContractAddress, amount)
      //    This requires WalletConnect personal_sign or eth_sendTransaction via _web3App

      await Future.delayed(const Duration(seconds: 1)); // Mock delay

      onStatusChanged?.call('Purchasing Token...');
      // 2. Call Property Contract -> buy()

      await Future.delayed(const Duration(seconds: 1)); // Mock delay

      onStatusChanged?.call('Purchase complete!');
      return const Success("0xMOCK_TX_HASH_PURCHASE");
    } catch (e) {
      return Failure(UnknownError(e));
    }
  }

  Future<String> getNativeBalance() async {
    try {
      if (_sessionData == null) {
        return "0.00"; // Not connected
      }

      final addressStr = _sessionData!.namespaces['eip155']?.accounts.first
          .split(':')
          .last;

      if (addressStr == null) return "0.00";

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
      if (_sessionData == null) return const Failure(WalletNotConnected());

      onStatusChanged?.call('Preparing transfer...');
      // 1. Create contract object
      // 2. Encode transfer(to, amount)
      // 3. Send transaction

      await Future.delayed(const Duration(seconds: 2)); // Mock delay

      onStatusChanged?.call('Transfer successful!');
      return const Success("0xMOCK_TX_HASH_TRANSFER");
    } catch (e) {
      return Failure(UnknownError(e));
    }
  }

  Future<double> getTokenBalance(String tokenAddress) async {
    // 1. Create DeployedContract (ERC20)
    // 2. Call balanceOf(userAddress)
    // 3. Return formatted value
    if (tokenAddress == '0x1234567890123456789012345678901234567890') {
      // Mock balance for "The Orion Penthouse" if purchased
      // In a real app, this would query the chain.
      // For MVP demo, we can simulate a balance if we "bought" it.
      // But for now, let's return a static 500.0 to show it "Works" if connected.
      if (_sessionData != null) return 500.0;
    }
    return 0.0;
  }

  // Placeholder for getting deployed properties from Factory
  Future<List<String>> getDeployedProperties() async {
    // Structure for Production Sync:
    // 1. Create DeployedContract object using _factoryAddress and _factoryAbi
    // 2. Client.getLogs() filtering by 'PropertyDeployed' event
    // 3. Parse logs to extract new Property Contract Addresses
    // 4. Return list of addresses

    // final factory = DeployedContract(ContractAbi.fromJson(_factoryAbi, 'PropertyFactory'), EthereumAddress.fromHex(_factoryAddress));
    // final event = factory.event('PropertyDeployed');
    // ... implementation ...

    return [];
  }
}
