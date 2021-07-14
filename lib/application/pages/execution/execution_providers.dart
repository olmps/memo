import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';

/// Overridable collection id used in the scope of a collection execution
///
/// Throws an `UnsupportedError` if the consuming context don't override this provider
final executionCollectionId = ScopedProvider<String>(null);

/// Syntax sugar for `context.read` the current [CollectionExecutionVM] provider.
CollectionExecutionVM readExecutionVM(BuildContext context) {
  final collectionId = context.read(executionCollectionId);
  return context.read(collectionExecutionVM(collectionId));
}

/// Syntax sugar for calling [useProvider] with both [collectionExecutionVM] and [executionCollectionId] providers.
CollectionExecutionState useCollectionExecutionState() {
  final collectionId = useProvider(executionCollectionId);
  return useProvider(collectionExecutionVM(collectionId).state);
}
