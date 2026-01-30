import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/property_repository.dart';

final propertyListProvider = StreamProvider<List<Property>>((ref) {
  return ref.watch(propertyRepositoryProvider).getProperties();
});
