import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';

/// Provides a overridable current to with a [ScopedProvider]
///
/// There is no default value (meaning `null`) for this provider, it must always be supplied to any widget that uses it
final executionCollectionId = ScopedProvider<String>(null);

/// Syntax sugar for **reading** the current [CollectionExecutionVM] instance
CollectionExecutionVM readExecutionVM(BuildContext context) {
  final collectionId = context.read(executionCollectionId);
  return context.read(collectionExecutionVM(collectionId));
}

/// Syntax sugar for calling [useProvider] with both [collectionExecutionVM] and [executionCollectionId] providers
CollectionExecutionState useCollectionExecutionState() {
  final collectionId = useProvider(executionCollectionId);
  return useProvider(collectionExecutionVM(collectionId).state);
}
