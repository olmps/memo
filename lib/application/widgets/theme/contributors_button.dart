import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/theme/link.dart';
import 'package:memo/domain/models/contributor.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/utils/bottom_sheet.dart';

class MultipleContributorsButton extends HookWidget {
  const MultipleContributorsButton(this.contributors);

  final List<Contributor> contributors;

  void _showBottomSheet(BuildContext context, Color backgroundColor, Color imageBackgroundColor) {
    context.showDraggableScrollableModalBottomSheet<void>(
      child: Column(
        children: contributors
            .map((contributor) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: dimens.contributorsButtonVerticalPadding,
                    horizontal: dimens.contributorsButtonHorizontalPadding,
                  ),
                  child: SingleContributorButton(
                    contributor,
                    imageRadius: dimens.contributorsLargeImageRadius,
                    backgroundColor: backgroundColor,
                    imageBackgroundColor: imageBackgroundColor,
                  ),
                ))
            .toList(),
      ),
      title: strings.contributorsTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoTheme = useTheme();

    final themeColor = memoTheme.neutralSwatch.shade200;
    final description = strings.numOfContributors(contributors.length);
    final maxImages =
        contributors.length > dimens.maxContributorsImages ? dimens.maxContributorsImages : contributors.length;

    final contributorsImages = contributors
        .sublist(0, maxImages)
        .asMap()
        .map((index, contributor) => MapEntry(
            index,
            Padding(
              padding: EdgeInsets.only(right: index * dimens.contributorsImagePadding),
              child: CircleAvatar(
                backgroundColor: memoTheme.neutralSwatch.shade900,
                radius: dimens.contributorsSmallImageRadius + dimens.contributorsImageBorderWidth,
                child: CircleAvatar(
                  radius: dimens.contributorsSmallImageRadius,
                  backgroundImage: NetworkImage(
                    contributor.imageUrl,
                  ),
                  backgroundColor: memoTheme.neutralSwatch.shade800,
                ),
              ),
            )))
        .values
        .toList()
        .reversed
        .toList();

    final trailing = Stack(
      alignment: Alignment.centerRight,
      children: contributorsImages,
    );

    return LinkButton(
      onTap: () => _showBottomSheet(
        context,
        memoTheme.neutralSwatch.shade800,
        memoTheme.neutralSwatch.shade900,
      ),
      text: description,
      backgroundColor: memoTheme.neutralSwatch.shade900,
      textStyle: TextStyle(color: themeColor),
      trailing: trailing,
    );
  }
}

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
    final memoTheme = useTheme();

    final iconColor = memoTheme.neutralSwatch.shade200;
    final avatarBackgroundColor = imageBackgroundColor ?? memoTheme.neutralSwatch.shade800;
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
