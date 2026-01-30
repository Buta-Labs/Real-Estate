import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';

class PortfolioItem {
  final Property property;
  final double balance; // Number of tokens owned

  PortfolioItem({required this.property, required this.balance});

  double get currentValue => balance * property.price;
}
