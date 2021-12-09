import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';

/// Throws an [UnimplementedError] if the consuming [ProviderScope] doesn't override this provider.
final executionCollectionId = Provider<String>((_) => throw UnimplementedError(), name: 'executionCollectionId');

/// Syntax sugar for reading [collectionExecutionVM], using currently-scoped [executionCollectionId].
CollectionExecutionVM readExecutionVM(WidgetRef ref) {
  final collectionId = ref.read(executionCollectionId);
  return ref.read(collectionExecutionVM(collectionId).notifier);
}

/// Syntax sugar for watching [collectionExecutionVM] state, using the scoped [executionCollectionId].
CollectionExecutionState watchCollectionExecutionState(WidgetRef ref) {
  final collectionId = ref.watch(executionCollectionId);
  return ref.watch(collectionExecutionVM(collectionId));
}
