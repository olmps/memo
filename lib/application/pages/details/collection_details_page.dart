import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/coordinator/routes_coordinator.dart';
import 'package:memo/application/pages/details/contributor_view.dart';
import 'package:memo/application/pages/details/details_providers.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/details/collection_details_vm.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/item_collection_card.dart';
import 'package:memo/application/widgets/theme/resources_list.dart';
import 'package:memo/application/widgets/theme/themed_container.dart';
import 'package:memo/application/widgets/theme/themed_text_tag.dart';

class CollectionDetailsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoTheme = ref.watch(themeController);
    final state = watchCollectionDetailsState(ref);

    if (state is LoadedCollectionDetailsState) {
      final sections = <Widget>[];

      final heroCollectionCard = ThemedTopContainer(
        child: buildCollectionCardFromItem(
          state.metadata,
          padding: EdgeInsets.only(
            // The top spacing must take into consideration both the safe area and the toolbar height, as this page's
            // scaffold `extendBodyBehindAppBar` is set to `true`, thus this collection card will be placed behind
            // the app bar.
            top: context.rawSpacing(Spacing.large) + kToolbarHeight + MediaQuery.of(context).padding.top,
            right: context.rawSpacing(Spacing.small),
            bottom: context.rawSpacing(Spacing.large),
            left: context.rawSpacing(Spacing.small),
          ),
          hasBorder: false,
        ),
      );

      final descriptionSection = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, ref, strings.detailsDescription),
          context.verticalBox(Spacing.small),
          Text(state.description),
          context.verticalBox(Spacing.small),
          NeutralTextTag(strings.detailsTotalMemos(state.memosAmount).toUpperCase()),
          context.verticalBox(Spacing.large),
          if (state.contributors.length > 1)
            MultiContributorsView(state.contributors)
          else
            SingleContributorView(state.contributors.first),
        ],
      );

      sections.add(descriptionSection);

      final resources = state.resources;
      final resourcesSection = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, ref, strings.detailsResources),
          context.verticalBox(Spacing.small),
          Text(
            strings.detailsResourcesWarning,
            style: Theme.of(context).textTheme.caption?.copyWith(color: memoTheme.neutralSwatch.shade300),
          ),
          context.verticalBox(Spacing.small),
          ResourcesList(
            itemCount: resources.length,
            resourceDescriptionBuilder: (index) => resources[index].description,
            resourceTypeBuilder: (index) => resources[index].type,
            resourceUrlBuilder: (index) => resources[index].url,
          ),
        ],
      );

      sections.add(resourcesSection);

      final fixedBottomAction = ThemedBottomContainer(
        child: Container(
          color: memoTheme.neutralSwatch.shade800,
          child: SafeArea(
            child: PrimaryElevatedButton(
              onPressed: () {
                final id = ref.read(detailsCollectionId);
                readCoordinator(ref).navigateToCollectionExecution(id, isNestedNavigation: false);
              },
              text: strings.detailsStudyNow.toUpperCase(),
            ).withSymmetricalPadding(context, vertical: Spacing.small, horizontal: Spacing.medium),
          ),
        ),
      );

      return Scaffold(
        appBar: AppBar(title: const Text(strings.details)),
        extendBodyBehindAppBar: true,
        // By using the `bottomNavigationBar`, this widgets height will be padded accordingly to conform to any scroll
        // view in this scaffold's `body`.
        bottomNavigationBar: fixedBottomAction,
        body: Column(
          children: [
            heroCollectionCard,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  // Iterate through all sections and add a suitable top spacing.
                  children: sections
                      .map((section) => [context.verticalBox(Spacing.xLarge), section])
                      .expand((element) => element)
                      .toList(),
                ).withOnlyPadding(context, left: Spacing.medium, right: Spacing.medium, bottom: Spacing.xLarge),
              ),
            ),
          ],
        ),
      );
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildSectionTitle(BuildContext context, WidgetRef ref, String text) => Text(
        text,
        style:
            Theme.of(context).textTheme.subtitle1?.copyWith(color: ref.watch(themeController).neutralSwatch.shade300),
      );
}
