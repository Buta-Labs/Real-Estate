import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';

class PortfolioItem {
  final Property property;
  final double balance; // Number of tokens owned
  final double claimableRent;

  PortfolioItem({
    required this.property,
    required this.balance,
    this.claimableRent = 0.0,
  });

  double get currentValue => balance * property.price;
}
