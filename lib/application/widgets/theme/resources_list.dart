import 'package:flutter/material.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/utils/scaffold_messenger.dart';
import 'package:memo/application/widgets/theme/link_button.dart';

import 'package:memo/domain/enums/resource_type.dart';

/// Represents a list of resources
///
/// See also:
///   - [ExternalLinkButton] which represents each resource item in this list, tappable to their respective URLs.
class ResourcesList extends StatelessWidget {
  const ResourcesList({
    required this.itemCount,
    required this.resourceDescriptionBuilder,
    required this.resourceTypeBuilder,
    required this.resourceUrlBuilder,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final int itemCount;
  final String Function(int index) resourceDescriptionBuilder;
  final ResourceType Function(int index) resourceTypeBuilder;
  final String Function(int index) resourceUrlBuilder;

  final ScrollPhysics physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final url = resourceUrlBuilder(index);
        final type = resourceTypeBuilder(index);
        final description = resourceDescriptionBuilder(index);

        final leadingEmoji = Text(
          strings.resourceEmoji(type),
          style: const TextStyle(fontSize: dimens.resourceLinkEmojiTextSize),
        );

        return ExternalLinkButton(
          url,
          description: description,
          leading: leadingEmoji,
          onFailLaunchingUrl: context.showExceptionSnackBar,
        ).withOnlyPadding(context, top: index != 0 ? Spacing.xSmall : null);
      },
    );
  }
}
