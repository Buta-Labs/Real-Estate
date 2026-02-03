abstract class BlockchainResult<T> {
  const BlockchainResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(BlockchainFailure failure) failure,
  });
}

class Success<T> extends BlockchainResult<T> {
  final T data;
  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(BlockchainFailure failure) failure,
  }) {
    return success(data);
  }
}

class Failure<T> extends BlockchainResult<T> {
  final BlockchainFailure failure;
  const Failure(this.failure);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(BlockchainFailure failure) failure,
  }) {
    return failure(this.failure);
  }
}

abstract class BlockchainFailure {
  final String message;
  const BlockchainFailure(this.message);
}

class UserRejected extends BlockchainFailure {
  const UserRejected() : super("User rejected the request.");
}

class NetworkError extends BlockchainFailure {
  const NetworkError([super.message = "Network connection failed."]);
}

class ContractError extends BlockchainFailure {
  const ContractError(super.message);
}

class WalletNotConnected extends BlockchainFailure {
  const WalletNotConnected() : super("Wallet not connected.");
}

class UnknownError extends BlockchainFailure {
  final dynamic error;
  const UnknownError(this.error) : super("An unknown error occurred.");
}
