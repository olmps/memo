import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/details/collection_details_vm.dart';

/// Provides an overridable collection id to be used in the scope of a collection details
///
/// There is no default value (meaning `null`) for this [ScopedProvider], it must always be supplied to any widget that
/// uses it
final detailsCollectionId = ScopedProvider<String>(null);

/// Syntax sugar for calling [useProvider] with both [collectionDetailsVM] and [detailsCollectionId] providers
CollectionDetailsState useCollectionDetailsState() {
  final collectionId = useProvider(detailsCollectionId);
  return useProvider(collectionDetailsVM(collectionId).state);
}
