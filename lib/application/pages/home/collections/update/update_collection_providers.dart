import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_metadata.dart';

/// Overridable collection id used in the scope of a collection update.
final updateCollectionId = Provider<String?>((_) => throw UnimplementedError(), name: 'updateCollectionId');

/// Overridable collection metadata used in the scope of a collection update.
final updateDetailsMetadata =
    Provider<CollectionUpdateMetadata>((_) => throw UnimplementedError(), name: 'updateDetailsMetadata');

/// Overridable memos metadata used in the scope of a collection update.
final updateMemosMetadata =
    Provider<List<MemoUpdateMetadata>>((_) => throw UnimplementedError(), name: 'updateMemosMetadata');
