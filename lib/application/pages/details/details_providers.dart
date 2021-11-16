import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/details/collection_details_vm.dart';

/// Overridable collection id used in the scope of a collection details
///
/// Throws an [UnimplementedError] if the consuming context don't override this provider
final detailsCollectionId = Provider<String>((_) => throw UnimplementedError(), name: 'detailsCollectionId');

/// Syntax sugar for watching [CollectionDetailsState] state updates.
CollectionDetailsState watchCollectionDetailsState(WidgetRef ref) {
  final collectionId = ref.watch(detailsCollectionId);
  return ref.watch(collectionDetailsVM(collectionId));
}
