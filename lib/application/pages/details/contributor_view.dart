import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/layoutr.dart';

import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/bottom_sheet.dart';
import 'package:memo/application/view-models/details/collection_details_vm.dart';
import 'package:memo/application/widgets/theme/link.dart';

/// Displays a custom-layout view for a list of [contributors].
///
/// When pressed, presents a modal bottom sheet with a list of all contributors.
///
/// See also:
///   - [SingleContributorView], which displays a single contributor.
class MultiContributorsView extends ConsumerWidget {
  const MultiContributorsView(this.contributors)
      : assert(
          contributors.length > 1,
          'At least 2 contributors must be provided. Use `SingleContributorView` instead.',
        );

  static const _visibleContributorsLimit = 5;

  final List<ContributorInfo> contributors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final contributorsAmount = contributors.length;

    return LinkButton(
      onTap: () {
        final list = ListView.builder(
          shrinkWrap: true,
          padding: context.symmetricInsets(vertical: Spacing.xSmall),
          itemCount: contributorsAmount,
          itemBuilder: (context, index) =>
              SingleContributorView(contributors[index]).withOnlyPadding(context, bottom: Spacing.xSmall),
        );

        showSnappableDraggableModalBottomSheet<dynamic>(
          context,
          title: strings.detailsContributors,
          child: list.withSymmetricalPadding(context, horizontal: Spacing.medium),
        );
      },
      text: strings.totalContributors(contributorsAmount),
      backgroundColor: theme.neutralSwatch.shade900,
      textStyle: TextStyle(color: theme.neutralSwatch.shade200),
      trailing: _buildContributorsStackedImages(context, contributorsAmount: contributorsAmount),
    );
  }

  Widget _buildContributorsStackedImages(BuildContext context, {required int contributorsAmount}) {
    final exceedsContributorsLimit = contributorsAmount > _visibleContributorsLimit;
    const overlappedSize = dimens.contributorImageSize * 0.8;

    final stackedContents = <Widget>[];

    // Displays a number of "additional" contributors that exceeded the contributors limit.
    if (exceedsContributorsLimit) {
      stackedContents.add(
        _ContributorImage(
          size: dimens.contributorImageSize,
          child: Text(
            '+${contributorsAmount - _visibleContributorsLimit}',
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
      );
    }

    final contributorsImgs = contributors
        .sublist(0, exceedsContributorsLimit ? _visibleContributorsLimit : contributorsAmount)
        .mapIndexed<Widget>(
          (index, contributor) => Padding(
            // Adds a padding proportional to its position in the stack.
            // The index must be shifted by 1 if `exceedsContributorsLimit` is `true`.
            padding: EdgeInsets.only(right: (index + (exceedsContributorsLimit ? 1 : 0)) * overlappedSize),
            child: _ContributorImage(size: dimens.contributorImageSize, url: contributor.imageUrl),
          ),
        )
        .toList();

    stackedContents.addAll(contributorsImgs);

    return Stack(alignment: Alignment.centerRight, children: stackedContents.reversed.toList());
  }
}

/// Displays a custom-layout view for a single [contributor].
///
/// Opens the contributor's URL if [ContributorInfo.url] is not `null`.
///
/// See also:
///   - [MultiContributorsView], which displays a list of contributors.
class SingleContributorView extends ConsumerWidget {
  const SingleContributorView(this.contributor);

  final ContributorInfo contributor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);

    final backgroundColor = theme.neutralSwatch.shade900;
    final textStyle = TextStyle(color: theme.neutralSwatch.shade200);

    final image = _ContributorImage(size: dimens.contributorImageSize, url: contributor.imageUrl);
    return contributor.url != null
        ? UrlLinkButton(
            contributor.url!,
            backgroundColor: backgroundColor,
            textStyle: textStyle,
            text: contributor.name,
            leading: image,
          )
        : LinkButton(
            onTap: null,
            backgroundColor: backgroundColor,
            textStyle: textStyle,
            text: contributor.name,
            leading: image,
          );
  }
}

/// Styles an image that represents a contributor.
///
/// Uses the [url] to build an [FadeInImage.assetNetwork], unless [child] is not `null`. If none are present, defaults
/// to an [Image] using a placeholder.
class _ContributorImage extends ConsumerWidget {
  const _ContributorImage({required this.size, this.url, this.child, Key? key}) : super(key: key);

  final String? url;
  final Widget? child;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neutralSwatch = ref.watch(themeController).neutralSwatch;

    final Widget contents;
    if (child != null) {
      contents = Container(
        color: neutralSwatch.shade800,
        width: size,
        height: size,
        child: Center(child: child),
      );
    } else if (url != null) {
      contents = FadeInImage.assetNetwork(
        image: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fadeInDuration: anims.imageFadeDuration,
        fadeInCurve: anims.defaultAnimationCurve,
        placeholder: images.userAvatarAsset,
        imageErrorBuilder: (_, __, ___) => Image.asset(images.userAvatarAsset),
      );
    } else {
      contents = Image.asset(images.userAvatarAsset, width: size, height: size);
    }

    return CircleAvatar(
      backgroundColor: neutralSwatch.shade900,
      radius: size / 2 + dimens.contributorImageBorderWidth / 2,
      child: ClipOval(child: contents),
    );
  }
}
