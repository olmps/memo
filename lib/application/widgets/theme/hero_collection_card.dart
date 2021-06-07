import 'package:flutter/material.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/view-models/item_metadata.dart';
import 'package:memo/application/widgets/theme/collection_card.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

const _collectionCardTag = 'collection_card';

/// Creates a [CollectionCard] from [item], wrapping it in a [Hero] element
///
/// When using this widget-wrapper, there should be at least two distinct pages wrapping the same element, otherwise it
/// won't work properly, as per [Hero] documentation.
Widget buildHeroCollectionCardFromItem(
  CollectionItem item, {
  required EdgeInsets padding,
  bool hasBorder = true,
  VoidCallback? onTap,
}) {
  String? progressDescription;
  double? progressValue;
  String? progressSemanticLabel;

  if (item is CompletedCollectionItem) {
    progressDescription = strings.recallLevel;
    progressValue = item.recallLevel;
    progressSemanticLabel = strings.linearIndicatorCollectionRecallLabel(item.readableRecall + strings.percentSymbol);
  } else if (item is IncompleteCollectionItem) {
    if (!item.isPristine) {
      progressDescription = strings.collectionCompletionProgress(
        current: item.executedUniqueMemos,
        target: item.totalUniqueMemos,
      );
      progressValue = item.isPristine ? null : item.completionPercentage;
      progressSemanticLabel =
          strings.linearIndicatorCollectionCompletionLabel(item.readableCompletion + strings.percentSymbol);
    }
  } else {
    throw InconsistentStateError.layout('Unsupported subtype (${item.runtimeType}) of `CollectionItem`');
  }

  return Hero(
    tag: '$_collectionCardTag-${item.id}',
    child: CollectionCard(
      name: item.name,
      tags: item.tags,
      padding: padding,
      hasBorder: hasBorder,
      progressDescription: progressDescription,
      progressValue: progressValue,
      progressSemanticLabel: progressSemanticLabel,
      onTap: onTap,
    ),
  );
}
