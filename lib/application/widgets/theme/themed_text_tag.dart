import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/text_tag.dart';

/// A [TextTag] that follows the layout's primary specs.
class PrimaryTextTag extends ConsumerWidget {
  const PrimaryTextTag(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextTag(
        text,
        backgroundColor: ref.watch(themeController).primarySwatch.shade600,
        padding: context.allInsets(Spacing.xxSmall),
        textStyle: Theme.of(context).textTheme.overline,
      );
}

/// A [TextTag] that follows the layout's secondary specs.
class SecondaryTextTag extends ConsumerWidget {
  const SecondaryTextTag(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextTag(
        text,
        backgroundColor: ref.watch(themeController).secondarySwatch.shade600,
        padding: context.allInsets(Spacing.xxSmall),
        textStyle: Theme.of(context).textTheme.overline,
      );
}

/// A [TextTag] that follows the layout's neutral specs.
class NeutralTextTag extends ConsumerWidget {
  const NeutralTextTag(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextTag(
        text,
        backgroundColor: ref.watch(themeController).neutralSwatch.shade800,
        padding: context.allInsets(Spacing.xxSmall),
        textStyle: Theme.of(context).textTheme.overline,
      );
}
