import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';

/// Overridable collection id used in the scope of a collection execution
///
/// Throws an [UnimplementedError] if the consuming context don't override this provider
final executionCollectionId = Provider<String>((_) => throw UnimplementedError(), name: 'executionCollectionId');

/// Syntax sugar for `ref.watch` the current [CollectionExecutionVM] provider.
CollectionExecutionVM readExecutionVM(WidgetRef ref) {
  final collectionId = ref.watch(executionCollectionId);
  return ref.watch(collectionExecutionVM(collectionId).notifier);
}

/// Syntax sugar for watching for [CollectionExecutionState] state updates.
CollectionExecutionState useCollectionExecutionState(WidgetRef ref) {
  final collectionId = ref.watch(executionCollectionId);
  return ref.watch(collectionExecutionVM(collectionId));
}
