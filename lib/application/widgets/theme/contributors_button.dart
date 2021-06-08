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

  void _showBottomSheet(BuildContext context, Color backgroundColor) {
    context.showDraggableScrollableModalBottomSheet<void>(
      child: ListView.builder(
        itemCount: contributors.length,
        itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: dimens.contributorsButtonVerticalPadding,
                  horizontal: dimens.contributorsButtonHorizontalPadding,
                ),
                child: SingleContributorButton(
                  contributors[index],
                  imageRadius: dimens.contributorsLargeImageRadius,
                  backgroundColor: backgroundColor,
                ),
              ),
            ),
      title: strings.contributorsTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoTheme = useTheme();

    final themeColor = memoTheme.neutralSwatch.shade200;
    final backgroundThemeColor = memoTheme.neutralSwatch.shade900;
    final imageBackgroundColor = memoTheme.neutralSwatch.shade800;
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
                backgroundColor: backgroundThemeColor,
                radius: dimens.contributorsSmallImageRadius + dimens.contributorsImageBorderWidth,
                child: CircleAvatar(
                  radius: dimens.contributorsSmallImageRadius,
                  backgroundImage: NetworkImage(
                    contributor.imageUrl,
                  ),
                  backgroundColor: imageBackgroundColor,
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
      onTap: () => _showBottomSheet(context, imageBackgroundColor),
      text: description,
      backgroundColor: backgroundThemeColor,
      textStyle: TextStyle(color: themeColor),
      trailing: trailing,
    );
  }
}

class SingleContributorButton extends HookWidget {
  const SingleContributorButton(
    this.contributor, {
    this.backgroundColor,
    this.imageRadius,
    this.textStyle,
  });

  final Contributor contributor;

  final Color? backgroundColor;

  final double? imageRadius;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final memoTheme = useTheme();

    final iconColor = memoTheme.neutralSwatch.shade200;
    final imageBackgroundColor = memoTheme.neutralSwatch.shade800;
    final url = contributor.url;
    final description = contributor.name;
    final leading = CircleAvatar(
      radius: imageRadius ?? dimens.contributorsSmallImageRadius,
      backgroundImage: NetworkImage(
        contributor.imageUrl,
      ),
      backgroundColor: imageBackgroundColor,
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
