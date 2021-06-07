import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/theme/link.dart';
import 'package:memo/domain/models/contributor.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/strings.dart' as strings;

class MultipleContributorsButton extends HookWidget {
  const MultipleContributorsButton(this.contributors);

  final List<Contributor> contributors;

  @override
  Widget build(BuildContext context) {
    final themeColor = useTheme().neutralSwatch.shade200;
    final imageBackgroundColor = useTheme().neutralSwatch.shade800;
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
                radius: dimens.contributorsImageRadius,
                backgroundImage: NetworkImage(
                  contributor.imageUrl,
                ),
                backgroundColor: imageBackgroundColor,
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
      onTap: () {},
      text: description,
      backgroundColor: Colors.transparent,
      textStyle: TextStyle(color: themeColor),
      trailing: trailing,
    );
  }
}

class SingleContributorButton extends HookWidget {
  const SingleContributorButton(this.contributor);

  final Contributor contributor;

  @override
  Widget build(BuildContext context) {
    final themeColor = useTheme().neutralSwatch.shade200;
    final imageBackgroundColor = useTheme().neutralSwatch.shade800;
    final url = contributor.url;
    final description = contributor.name;
    final leading = CircleAvatar(
      radius: dimens.contributorsImageRadius,
      backgroundImage: NetworkImage(
        contributor.imageUrl,
      ),
      backgroundColor: imageBackgroundColor,
    );

    return ExternalLinkButton(
      url,
      description: description,
      leading: leading,
      backgroundColor: Colors.transparent,
      textStyle: TextStyle(color: themeColor),
      iconColor: themeColor,
    );
  }
}
