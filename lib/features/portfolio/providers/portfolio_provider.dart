import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/core/blockchain/blockchain_repository.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/property_repository.dart';
import 'package:orre_mmc_app/features/portfolio/models/portfolio_item.dart';

final portfolioAssetsProvider = FutureProvider.autoDispose<List<PortfolioItem>>(
  (ref) async {
    final propertyRepo = ref.watch(propertyRepositoryProvider);
    final blockchainRepo = ref.read(blockchainRepositoryProvider);

    // 1. Get all known properties
    final allProperties = await propertyRepo.getProperties().first;

    // 2. Filter for ones where user has > 0 balance
    final List<PortfolioItem> ownedItems = [];

    for (final property in allProperties) {
      if (property.contractAddress.isNotEmpty) {
        final balance = await blockchainRepo.getTokenBalance(
          property.contractAddress,
        );
        if (balance > 0) {
          final claimable = await blockchainRepo.getClaimableRent(
            property.contractAddress,
          );
          ownedItems.add(
            PortfolioItem(
              property: property,
              balance: balance,
              claimableRent: claimable,
            ),
          );
        }
      }
    }

    return ownedItems;
  },
);
