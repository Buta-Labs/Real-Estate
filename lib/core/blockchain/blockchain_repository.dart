import 'package:reown_appkit/reown_appkit.dart';
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
      '0x3793d34F8fB97665c530414307A035D9441a524e';

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

  static const String usdcAddress =
      '0x036CbD53842c5426634e7929541eC2318f3dCF7e';

  Future<BlockchainResult<String>> purchaseToken(
    String propertyContractAddress,
    double amount, {
    String? legalDocHash, // PDF hash for legal compliance
    Function(String)? onStatusChanged,
  }) async {
    try {
      if (!_appKitModal.isConnected) return const Failure(WalletNotConnected());

      final senderAddressStr = _appKitModal
          .session
          ?.namespaces?['eip155']
          ?.accounts
          .first
          .split(':')
          .last;
      if (senderAddressStr == null) {
        return const Failure(UnknownError('No account found'));
      }
      final senderAddress = EthereumAddress.fromHex(senderAddressStr);
      final propertyAddress = EthereumAddress.fromHex(propertyContractAddress);
      final usdcAddr = EthereumAddress.fromHex(usdcAddress);

      // 1. Fetch Price per Token to calculate total Cost
      onStatusChanged?.call('Fetching current price...');

      const priceAbi =
          '[{"inputs":[],"name":"pricePerToken","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]';
      final propertyContract = DeployedContract(
        ContractAbi.fromJson(priceAbi, 'PropertyToken'),
        propertyAddress,
      );
      final priceFunc = propertyContract.function('pricePerToken');

      final priceResult = await _client.call(
        contract: propertyContract,
        function: priceFunc,
        params: [],
      );
      final pricePerToken = priceResult.first as BigInt;

      // Calculate Total Cost: amount * pricePerToken
      // Amount is usually entered as "5 tokens". If input `amount` is double, we handle it.
      // Assuming amount is integer-like for now as per previous logic (BigInt.from(amount)).
      // If amount allows decimals (fractional tokens), we need to clarify decimals of PropertyToken (18).
      final amountBigInt = BigInt.from(amount);
      final totalCost = amountBigInt * pricePerToken;

      // 2. Check USDC Allowance
      onStatusChanged?.call('Checking USDC allowance...');

      const erc20Abi =
          '[{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]';

      final usdcContract = DeployedContract(
        ContractAbi.fromJson(erc20Abi, 'USDC'),
        usdcAddr,
      );

      final allowanceFunc = usdcContract.function('allowance');
      final allowanceResult = await _client.call(
        contract: usdcContract,
        function: allowanceFunc,
        params: [senderAddress, propertyAddress],
      );
      final currentAllowance = allowanceResult.first as BigInt;

      // 3. Approve if necessary
      if (currentAllowance < totalCost) {
        onStatusChanged?.call('Approving USDC...');

        final approveFunc = usdcContract.function('approve');
        final approveData = approveFunc.encodeCall([
          propertyAddress,
          totalCost,
        ]);

        final approveDataHex =
            '0x${approveData.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

        final approveTx = {
          'from': senderAddressStr,
          'to': usdcAddress,
          'data': approveDataHex,
        };

        final approveHash = await _appKitModal.request(
          topic: _appKitModal.session!.topic!,
          chainId: 'eip155:$chainId',
          request: SessionRequestParams(
            method: 'eth_sendTransaction',
            params: [approveTx],
          ),
        );

        onStatusChanged?.call('Waiting for approval to confirm...');

        // WAIT for transaction receipt
        // We need a loop to check receipt or use a helper.
        // Since appKitModal.request doesn't wait for mining, we must poll _client.
        bool confirmed = false;
        int attempts = 0;
        while (!confirmed && attempts < 30) {
          // Wait up to ~60-90s
          await Future.delayed(const Duration(seconds: 2));
          final receipt = await _client.getTransactionReceipt(
            approveHash.toString(),
          );
          if (receipt != null && receipt.status == true) {
            // status=1 usually means success
            confirmed = true;
          }
          attempts++;
        }

        if (!confirmed) {
          return const Failure(
            UnknownError('Approval transaction timed out or failed'),
          );
        }
      }

      // 4. Invest
      onStatusChanged?.call('Confirming Investment... Please sign in wallet.');

      // ABI for invest function
      const investAbi =
          '[{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"string","name":"legalDocHashSigned","type":"string"}],"name":"invest","outputs":[],"stateMutability":"nonpayable","type":"function"}]';

      final investContract = DeployedContract(
        ContractAbi.fromJson(investAbi, 'PropertyToken'),
        propertyAddress,
      );

      final investFunc = investContract.function('invest');

      final investData = investFunc.encodeCall([
        amountBigInt,
        legalDocHash ?? "Signed",
      ]);

      final investDataHex =
          '0x${investData.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

      final investTx = {
        'from': senderAddressStr,
        'to': propertyContractAddress,
        'data': investDataHex,
      };

      final result = await _appKitModal.request(
        topic: _appKitModal.session!.topic!,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [investTx],
        ),
      );

      onStatusChanged?.call('Investment Transaction Submitted!');
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
      // Updated to 6 Decimals as per new Standard
      final amountInUnits = BigInt.from(amount * 1000000);
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
    try {
      if (!_appKitModal.isConnected) return 0.0;

      final addressStr = _appKitModal
          .session
          ?.namespaces?['eip155']
          ?.accounts
          .first
          .split(':')
          .last;
      if (addressStr == null) return 0.0;
      final ownerAddress = EthereumAddress.fromHex(addressStr);

      const abi =
          '[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]';
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'ERC20'),
        EthereumAddress.fromHex(tokenAddress),
      );

      final balanceFunc = contract.function('balanceOf');
      final result = await _client.call(
        contract: contract,
        function: balanceFunc,
        params: [ownerAddress],
      );

      final balance = result.first as BigInt;
      // Assuming 6 decimals for USDC. If generic, we should fetch decimals() first.
      // For now, hardcoding 6 decimals as mostly we use USDC.
      return balance.toDouble() / 1000000.0;
    } catch (e) {
      debugPrint('Error fetching token balance: $e');
      return 0.0;
    }
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
          '[{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"pricePerToken","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"legalDocHash","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"tier","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"currentStatus","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalRaised","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"targetRaiseAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]';
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'PropertyToken'),
        EthereumAddress.fromHex(address),
      );

      final nameFunc = contract.function('name');
      final priceFunc = contract.function('pricePerToken');
      final docFunc = contract.function('legalDocHash');
      final tierFunc = contract.function('tier');
      final statusFunc = contract.function('currentStatus');
      final raisedFunc = contract.function('totalRaised');
      final targetFunc = contract.function('targetRaiseAmount');

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
      final statusResult = await _client.call(
        contract: contract,
        function: statusFunc,
        params: [],
      );
      final raisedResult = await _client.call(
        contract: contract,
        function: raisedFunc,
        params: [],
      );
      final targetResult = await _client.call(
        contract: contract,
        function: targetFunc,
        params: [],
      );

      return {
        'name': nameResult.first as String,
        'price':
            (priceResult.first as BigInt).toDouble() /
            1000000.0, // Assuming 6 decimals like USDC
        'legalDocHash': docResult.first as String,
        'tierIndex': (tierResult.first as BigInt).toInt(),
        'status': (statusResult.first as BigInt).toInt(),
        'totalRaised': (raisedResult.first as BigInt).toDouble() / 1000000.0,
        'targetRaise': (targetResult.first as BigInt).toDouble() / 1000000.0,
      };
    } catch (e) {
      debugPrint('Error fetching property details for $address: $e');
      return {};
    }
  }

  Future<double> getClaimableRent(String propertyAddress) async {
    try {
      if (!_appKitModal.isConnected) return 0.0;
      final senderAddressStr = _appKitModal
          .session
          ?.namespaces?['eip155']
          ?.accounts
          .first
          .split(':')
          .last;
      if (senderAddressStr == null) return 0.0;
      final senderAddress = EthereumAddress.fromHex(senderAddressStr);

      const abi =
          '[{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"getClaimableRent","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]';
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'PropertyToken'),
        EthereumAddress.fromHex(propertyAddress),
      );

      final func = contract.function('getClaimableRent');
      final result = await _client.call(
        contract: contract,
        function: func,
        params: [senderAddress],
      );

      final amount = result.first as BigInt;
      // Result is in USDC decimals (6)
      return amount.toDouble() / 1000000.0;
    } catch (e) {
      debugPrint('Error fetching claimable rent: $e');
      return 0.0;
    }
  }

  Future<BlockchainResult<String>> claimRent(
    String propertyAddress, {
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

      onStatusChanged?.call('Please sign to claim rent...');

      const abi =
          '[{"inputs":[],"name":"claimRent","outputs":[],"stateMutability":"nonpayable","type":"function"}]';
      final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'PropertyToken'),
        EthereumAddress.fromHex(propertyAddress),
      );
      final claimFunc = contract.function('claimRent');
      final data = claimFunc.encodeCall([]);
      final dataHex =
          '0x${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

      final tx = {
        'from': senderAddress,
        'to': propertyAddress,
        'data': dataHex,
      };

      final result = await _appKitModal.request(
        topic: _appKitModal.session!.topic!,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [tx],
        ),
      );

      onStatusChanged?.call('Claim Transaction Submitted!');
      return Success(result.toString());
    } catch (e) {
      return Failure(UnknownError(e));
    }
  }
}
