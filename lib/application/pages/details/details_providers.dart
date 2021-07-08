import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/details/collection_details_vm.dart';

/// Overridable collection id used in the scope of a collection details
///
/// Throws an `UnsupportedError` if the consuming context don't override this provider
final detailsCollectionId = ScopedProvider<String>(null);

/// Syntax sugar for calling [useProvider] with both [collectionDetailsVM] and [detailsCollectionId] providers
CollectionDetailsState useCollectionDetailsState() {
  final collectionId = useProvider(detailsCollectionId);
  return useProvider(collectionDetailsVM(collectionId).state);
}
