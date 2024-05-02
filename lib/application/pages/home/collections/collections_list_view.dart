import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/coordinator/routes_coordinator.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/bottom_sheet.dart';
import 'package:memo/application/utils/scaffold_messenger.dart';
import 'package:memo/application/view-models/home/collections_vm.dart';
import 'package:memo/application/view-models/item_metadata.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/item_collection_card.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

class CollectionsListView extends ConsumerWidget {
  const CollectionsListView(this.items);

  final List<ItemMetadata> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(collectionsVM.notifier);

    ref.listen(collectionsVM, (_, state) {
      if (state is PurchaseCollectionFailed) {
        Navigator.of(context).pop();
        showExceptionSnackBar(ref, state.exception);
      }
      if (state is PurchaseCollectionSuccess) {
        Navigator.of(context).pop();
        showSnackBar(
          ref,
          const SnackBar(
            content: Text(strings.collectionSuccessPurchase),
          ),
        );
      }
    });

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
            onTap: item.isAvailable
                ? () => readCoordinator(ref).navigateToCollectionDetails(item.id)
                : () async => collectionPurchaseBottomSheet(context, () => vm.purchaseCollection(item.id)),
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

/// This Modal Bottom Sheet representing the option to purchase a specific `Collection`.
Future<void> collectionPurchaseBottomSheet(BuildContext context, VoidCallback? onPressed) =>
    showSnappableDraggableModalBottomSheet<void>(
      context,
      title: strings.collectionPurchase,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          context.verticalBox(Spacing.xLarge),
          PrimaryElevatedButton(text: strings.purchase, onPressed: onPressed),
          context.verticalBox(Spacing.medium),
          SecondaryElevatedButton(text: strings.cancel, onPressed: Navigator.of(context).pop),
        ],
      ).withAllPadding(context, Spacing.medium),
    );
