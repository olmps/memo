import 'package:memo/data/repositories/resource_repository.dart';
import 'package:memo/domain/models/resource.dart';

/// Handles all domain-specific operations associated with [Resource]s.
abstract class ResourceServices {
  /// Retrieves all [Resource]s that have at least one of the values in [tags].
  Future<List<Resource>> getResourcesWithAnyTags(List<String> tags);
}

class ResourceServicesImpl implements ResourceServices {
  ResourceServicesImpl(this.resourceRepo);

  final ResourceRepository resourceRepo;

  @override
  Future<List<Resource>> getResourcesWithAnyTags(List<String> tags) =>
      resourceRepo.getAllResources(associatedTags: tags);
}
