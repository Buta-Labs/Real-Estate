import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_model.dart';
import 'package:orre_mmc_app/features/marketplace/models/property_status.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/project_repository.dart';
import 'package:orre_mmc_app/features/marketplace/repositories/property_repository.dart';

final propertyListProvider = StreamProvider<List<Property>>((ref) {
  final propertiesStream = ref
      .watch(propertyRepositoryProvider)
      .getProperties();
  final projectsAsync = ref.watch(projectListProvider);

  return propertiesStream.map((properties) {
    return projectsAsync.when(
      data: (projects) {
        final projectMap = {for (var p in projects) p.id: p};

        return properties.map((property) {
          final project = projectMap[property.projectId];
          if (project == null) return property;

          // Visibility Inheritance
          if (project.status == PropertyStatus.hidden) {
            return property.copyWith(status: PropertyStatus.hidden);
          }
          if (project.status == PropertyStatus.comingSoon &&
              property.status == PropertyStatus.active) {
            // Force Coming Soon if Project is Coming Soon but Property is Active
            return property.copyWith(status: PropertyStatus.comingSoon);
          }
          if (project.status == PropertyStatus.soldOut &&
              property.status == PropertyStatus.active) {
            // Force Sold Out if Project is Sold Out
            return property.copyWith(status: PropertyStatus.soldOut);
          }

          return property;
        }).toList();
      },
      loading: () => properties,
      error: (_, _) => properties,
    );
  });
});
