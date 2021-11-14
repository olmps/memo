import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';

/// Overridable collection id used in the scope of a collection update.
final updateCollectionId = Provider<String?>((_) => throw UnimplementedError(), name: 'updateCollectionId');

/// Syntax sugar for listening to [UpdateCollectionState] state updates.
UpdateCollectionState useUpdateCollectionState(WidgetRef ref) {
  final collectionId = ref.watch(updateCollectionId);
  return ref.watch(updateCollectionVM(collectionId));
}

/// Syntax sugar for `ref.watch` the current [UpdateCollectionVM] provider.
UpdateCollectionVM useUpdateCollectionVM(WidgetRef ref) {
  final collectionId = ref.watch(updateCollectionId);
  return ref.watch(updateCollectionVM(collectionId).notifier);
}
