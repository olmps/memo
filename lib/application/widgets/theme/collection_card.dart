import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/colors.dart' as colors;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/memo_theme_data.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/animatable_progress.dart';
import 'package:memo/application/widgets/theme/themed_text_tag.dart';

/// Represents a collection card.
///
/// See also:
///   - `buildHeroCollectionCardFromItem`, which creates this exact same card but for [Hero] transitions.
class CollectionCard extends ConsumerWidget {
  CollectionCard({
    required this.name,
    required this.tags,
    required this.padding,
    this.hasBorder = true,
    this.progressDescription,
    this.progressValue,
    this.progressSemanticLabel,
    this.onTap,
    Key? key,
  })  : assert(tags.isNotEmpty),
        super(key: key);

  /// Name for this collection.
  final String name;

  /// List of tags associated with this collection.
  final List<String> tags;

  /// If this widget should draw a border for this card.
  final bool hasBorder;

  /// Padding added between the card contents and its edges.
  final EdgeInsets padding;

  /// Auxiliar description to describe this collection's progress.
  final String? progressDescription;

  /// Raw value for this collection's generic progress value - ranging from 0 to 1.
  final double? progressValue;

  /// Accessibility description for this progress.
  final String? progressSemanticLabel;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final firstRowElements = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: Theme.of(context).textTheme.headline6),
        context.verticalBox(Spacing.xSmall),
        Flexible(child: _buildTagsWrap(context)),
      ],
    );

    // We are not using the `Card` widget because we need to customize the background with border + painter.
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: _buildCardDecoration(theme),
        child: CustomPaint(
          painter: _buildBackgroundPainter(theme),
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(child: firstRowElements),
                if (progressDescription != null && progressValue != null) ...[
                  context.verticalBox(Spacing.large),
                  _buildMemoryRecallTitle(context, theme),
                  context.verticalBox(Spacing.xSmall),
                  _buildMemoryRecallProgress(theme),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Decoration _buildCardDecoration(MemoThemeData theme) {
    final border = hasBorder
        ? Border.all(
            color: theme.neutralSwatch.shade300,
            width: dimens.cardBorderWidth,
          )
        : null;
    final borderRadius = hasBorder ? dimens.genericRoundedElementBorderRadius : null;

    return BoxDecoration(
      gradient: const LinearGradient(
        colors: colors.collectionCardGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: border,
      borderRadius: borderRadius,
    );
  }

  CustomPainter _buildBackgroundPainter(MemoThemeData theme) {
    return _CollectionCardBackgroundPainter(
      horizontalLineColor: theme.neutralSwatch.shade100,
      ovalGradientColors: colors.collectionCardGradient,
    );
  }

  Wrap _buildTagsWrap(BuildContext context) {
    final tagsSpacing = context.rawSpacing(Spacing.xSmall);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tagsSpacing,
      runSpacing: tagsSpacing,
      children: tags.map((tag) => PrimaryTextTag(tag.toUpperCase())).toList(),
    );
  }

  Text _buildMemoryRecallTitle(BuildContext context, MemoThemeData theme) {
    final captionColor = theme.neutralSwatch.shade200;
    final captionStyle = Theme.of(context).textTheme.caption;
    return Text(progressDescription!, style: captionStyle?.copyWith(color: captionColor));
  }

  Widget _buildMemoryRecallProgress(MemoThemeData theme) {
    final lineColor = theme.secondarySwatch.shade400;

    return AnimatableLinearProgress(
      value: progressValue!,
      animationCurve: anims.defaultAnimationCurve,
      animationDuration: anims.defaultAnimatableProgressDuration,
      lineSize: dimens.collectionsLinearProgressLineWidth,
      lineColor: lineColor,
      lineBackgroundColor: theme.neutralSwatch.shade900.withOpacity(0.4),
      semanticLabel: progressSemanticLabel,
    );
  }
}

/// Custom background painter for a Card that represents a `Collection`.
class _CollectionCardBackgroundPainter extends CustomPainter {
  _CollectionCardBackgroundPainter({required this.horizontalLineColor, required this.ovalGradientColors});

  final Color horizontalLineColor;
  final List<Color> ovalGradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    // Clip any additional drawings that exceed this bounds, like blurs.
    canvas.clipRect(Offset.zero & size);

    _drawMultipleHorizontalLines(canvas, size);
  }

  void _drawMultipleHorizontalLines(Canvas canvas, Size size) {
    const double horizontalLineSpacing = 2; // ignore: omit_local_variable_types
    const double horizontalLineHeight = 1; // ignore: omit_local_variable_types

    final horizontalLinePaint = Paint()
      ..strokeWidth = horizontalLineHeight
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [
          horizontalLineColor.withOpacity(0.03),
          horizontalLineColor.withOpacity(0.012),
          horizontalLineColor.withOpacity(0.03),
        ],
        [0, 0.5, 1],
      );

    // A horizontal line occurs every height+spacing points in height.
    const repeatDistance = horizontalLineSpacing + horizontalLineHeight;
    final totalLines = (size.height / repeatDistance).truncate();
    for (var lineIndex = 0; lineIndex <= totalLines; lineIndex++) {
      final double dy = lineIndex * 3; // ignore: omit_local_variable_types

      // Keep drawing full-width horizontal lines in the y axis, respecting the `totalLines`.
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), horizontalLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CollectionCardBackgroundPainter oldDelegate) =>
      horizontalLineColor != oldDelegate.horizontalLineColor || ovalGradientColors != oldDelegate.ovalGradientColors;
}
