import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/details/collection_details_vm.dart';

/// Throws an [UnimplementedError] if the consuming [ProviderScope] doesn't override this provider.
final detailsCollectionId = Provider<String>((_) => throw UnimplementedError(), name: 'detailsCollectionId');

/// Syntax sugar for watching [collectionDetailsVM] state, using the scoped [detailsCollectionId].
CollectionDetailsState watchCollectionDetailsState(WidgetRef ref) {
  final collectionId = ref.watch(detailsCollectionId);
  return ref.watch(collectionDetailsVM(collectionId));
}
