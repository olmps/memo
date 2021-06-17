import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:layoutr/layoutr.dart';

import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/theme/link.dart';
import 'package:memo/domain/models/contributor.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/utils/bottom_sheet.dart';

/// An alternative to the [SingleContributorButton]
/// when there's more than one contributor to a collection
///
/// This button meets the need of a layout to multiple contributors
/// wraping them togheter.
/// When tapped shows a modal bottom sheet
/// with a list of [SingleContributorButton]'s for each contributor.
class MultipleContributorsButton extends HookWidget {
  const MultipleContributorsButton(this.contributors);

  final List<Contributor> contributors;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();

    const _maxContributorsImage = 5;

    final maxImages = contributors.length > _maxContributorsImage ? _maxContributorsImage : contributors.length;

    final contributorsImages =
        contributors.sublist(0, maxImages).asMap().map(_buildContributorAvatar).values.toList().reversed.toList();

    final trailing = Stack(
      alignment: Alignment.centerRight,
      children: contributorsImages,
    );

    return LinkButton(
      onTap: () => _showBottomSheet(
        context,
        theme.neutralSwatch.shade800,
        theme.neutralSwatch.shade900,
      ),
      text: strings.numOfContributors(contributors.length),
      backgroundColor: theme.neutralSwatch.shade900,
      textStyle: TextStyle(color: theme.neutralSwatch.shade200),
      trailing: trailing,
    );
  }

  MapEntry<int, Widget> _buildContributorAvatar(int index, Contributor contributor) {
    final theme = useTheme();

    return MapEntry(
      index,
      Padding(
        padding: EdgeInsets.only(right: index * dimens.contributorsImagePadding),
        child: Container(
          width: dimens.contributorsSmallImageRadius,
          height: dimens.contributorsSmallImageRadius,
          padding: const EdgeInsets.all(dimens.contributorsImageBorderWidth), // borde width
          decoration: BoxDecoration(
            color: theme.neutralSwatch.shade800, // border color
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              contributor.imageUrl,
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Color backgroundColor, Color imageBackgroundColor) {
    context.showDraggableScrollableModalBottomSheet<void>(
      child: Column(
        children: contributors
            .map(
              (contributor) => SingleContributorButton(
                contributor,
                imageRadius: dimens.contributorsLargeImageRadius,
                backgroundColor: backgroundColor,
                imageBackgroundColor: imageBackgroundColor,
              ).withSymmetricalPadding(
                context,
                horizontal: Spacing.small,
                vertical: Spacing.xxSmall,
              ),
            )
            .toList(),
      ),
      title: strings.contributorsTitle,
    );
  }
}

/// A customizable button that shows the contributor information
/// and links its chosen url when tapped throught an `ExternalLinkButton`.
class SingleContributorButton extends HookWidget {
  const SingleContributorButton(
    this.contributor, {
    this.backgroundColor,
    this.imageBackgroundColor,
    this.imageRadius,
    this.textStyle,
  });

  final Contributor contributor;

  /// The button background color, if not present, the default value will be set
  final Color? backgroundColor;

  /// The color presented while the [contributor] image loads
  final Color? imageBackgroundColor;

  /// The radius of the [contributor] image
  final double? imageRadius;

  /// The text style of the [contributor] name
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();

    final iconColor = theme.neutralSwatch.shade200;
    final avatarBackgroundColor = imageBackgroundColor ?? theme.neutralSwatch.shade800;
    final url = contributor.url;
    final description = contributor.name;
    final leading = CircleAvatar(
      radius: imageRadius ?? dimens.contributorsSmallImageRadius,
      backgroundImage: NetworkImage(
        contributor.imageUrl,
      ),
      backgroundColor: avatarBackgroundColor,
    );

    return ExternalLinkButton(
      url,
      description: description,
      leading: leading,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      iconColor: iconColor,
    );
  }
}
