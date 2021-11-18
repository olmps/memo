import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';

/// Overridable collection id used in the scope of a collection update.
final updateCollectionId = Provider<String?>((_) => throw UnimplementedError(), name: 'updateCollectionId');

/// Overridable collection metadata used in the scope of a collection update.
final updateDetailsMetadata =
    Provider<CollectionMetadata>((_) => throw UnimplementedError(), name: 'updateDetailsMetadata');

/// Overridable memos metadata used in the scope of a collection update.
final updateMemosMetadata =
    Provider<List<MemoMetadata>>((_) => throw UnimplementedError(), name: 'updateMemosMetadata');
