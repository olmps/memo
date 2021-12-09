import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/coordinator/routes_coordinator.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/item_metadata.dart';
import 'package:memo/application/widgets/theme/item_collection_card.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

class CollectionsListView extends ConsumerWidget {
  const CollectionsListView(this.items);

  final List<ItemMetadata> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        // Builds the respective widget based on the item's `ItemMetadata` subtype.
        final item = items[index];

        if (item is CollectionsCategoryMetadata) {
          return _CollectionsSectionHeader(title: item.name)
              .withOnlyPadding(context, top: Spacing.xLarge, bottom: Spacing.small);
        } else if (item is CollectionItem) {
          return buildCollectionCardFromItem(
            item,
            padding: context.symmetricInsets(vertical: Spacing.large, horizontal: Spacing.small),
            onTap: () => readCoordinator(ref).navigateToCollectionDetails(item.id),
          ).withOnlyPadding(context, bottom: Spacing.medium);
        }

        throw InconsistentStateError.layout('Unsupported subtype (${item.runtimeType}) of `CollectionItemMetadata`');
      },
    );
  }
}

/// Header representing a category of multiple `Collection`s.
class _CollectionsSectionHeader extends ConsumerWidget {
  const _CollectionsSectionHeader({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleColor = ref.watch(themeController).neutralSwatch.shade300;
    final sectionTitleStyle = Theme.of(context).textTheme.headline6?.copyWith(color: titleColor);
    return Text(title, style: sectionTitleStyle);
  }
}
