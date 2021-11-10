import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';

/// Overridable collection id used in the scope of a collection update.
final updateCollectionId = ScopedProvider<String?>(null);

/// Syntax sugar for calling [useProvider] with both [updateCollectionVM] and [updateCollectionId] providers.
UpdateCollectionState useUpdateCollectionState() {
  final collectionId = useProvider(updateCollectionId);
  return useProvider(updateCollectionVM(collectionId).state);
}

/// Syntax sugar for `context.read` the current [UpdateCollectionVM] provider.
UpdateCollectionVM useUpdateCollectionVM(BuildContext context) {
  final collectionId = useProvider(updateCollectionId);
  return context.read(updateCollectionVM(collectionId));
}
