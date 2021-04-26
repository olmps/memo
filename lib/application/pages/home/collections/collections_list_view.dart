import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/colors.dart' as colors;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/collections_vm.dart';
import 'package:memo/application/widgets/animatable_progress.dart';
import 'package:memo/application/widgets/theme/themed_text_tag.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

class CollectionsListView extends HookWidget {
  const CollectionsListView() : super();

  @override
  Widget build(BuildContext context) {
    final state = useProvider(collectionsVM.state);

    if (state is LoadingCollectionsState) {
      return const Center(child: CircularProgressIndicator());
    }

    final loadedState = state as LoadedCollectionsState;
    final items = loadedState.collectionItems;

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        // Builds the respective widget based on the item's `CollectionItemMetadata` subtype
        final item = items[index];

        if (item is CollectionsCategoryMetadata) {
          return _CollectionsSectionHeader(
            title: item.name,
            onTap: () {},
          ).withOnlyPadding(context, top: Spacing.xLarge, bottom: Spacing.small);
        } else if (item is CompletedCollectionMetadata) {
          return _CollectionCard(
            name: item.name,
            tags: item.tags,
            progressDescription: strings.collectionsMemoryStability,
            progressValue: item.memoryStability,
          ).withOnlyPadding(context, bottom: Spacing.medium);
        } else if (item is IncompleteCollectionMetadata) {
          return _CollectionCard(
            name: item.name,
            tags: item.tags,
            progressDescription: strings.collectionsCompletionProgress(
              current: item.executedUniqueMemos,
              target: item.totalUniqueMemos,
            ),
            progressValue: item.completionPercentage,
          ).withOnlyPadding(context, bottom: Spacing.medium);
        }

        throw InconsistentStateError.layout('Unsupported subtype (${item.runtimeType} of `CollectionItemMetadata`');
      },
    );
  }
}

/// A header that is used when representing a category of multiple `Collection`s
class _CollectionsSectionHeader extends HookWidget {
  const _CollectionsSectionHeader({required this.title, required this.onTap, Key? key}) : super(key: key);

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = useTheme().neutralSwatch.shade300;
    final sectionTitleStyle = Theme.of(context).textTheme.headline6?.copyWith(color: titleColor);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(title, style: sectionTitleStyle)),
        TextButton(onPressed: onTap, child: Text(strings.collectionsSectionHeaderSeeAll.toUpperCase())),
      ],
    );
  }
}

class _CollectionCard extends HookWidget {
  _CollectionCard({
    required this.name,
    required this.tags,
    required this.progressDescription,
    required this.progressValue,
    Key? key,
  })  : assert(tags.isNotEmpty),
        super(key: key);

  /// Name for this collection
  final String name;

  /// Name for this collection
  final List<String> tags;

  /// Auxiliar description to describe this collection's progress
  final String? progressDescription;

  /// Raw value for this collection's generic progress value - ranging from 0 to 1
  final double? progressValue;

  @override
  Widget build(BuildContext context) {
    final memoTheme = useTheme();
    final borderColor = memoTheme.neutralSwatch.shade300;
    final wrapperDecoration = BoxDecoration(
      color: memoTheme.neutralSwatch.shade800,
      border: Border.all(
        color: borderColor,
        width: dimens.cardBorderWidth,
      ),
      borderRadius: dimens.genericRoundedElementBorderRadius,
    );

    final firstRowElements = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: Theme.of(context).textTheme.headline6),
        context.verticalBox(Spacing.xSmall),
        _buildTagsWrap(context),
      ],
    );

    final backgroundPainter = _CollectionCardBackgroundPainter(
      horizontalLineColor: memoTheme.neutralSwatch.shade100,
      ovalGradientColors: colors.collectionCardGradient,
    );

    // We are not using the `Card` widget because we need to customize the background with border + painter
    return Container(
      decoration: wrapperDecoration,
      child: CustomPaint(
        painter: backgroundPainter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(child: firstRowElements),
            if (progressDescription != null && progressValue != null) ...[
              context.verticalBox(Spacing.large),
              _buildMemoryStabilityTitle(context),
              context.verticalBox(Spacing.xSmall),
              _buildMemoryStabilityProgress(),
            ]
          ],
        ).withSymmetricalPadding(context, vertical: Spacing.large, horizontal: Spacing.small),
      ),
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

  Text _buildMemoryStabilityTitle(BuildContext context) {
    final memoTheme = useTheme();
    final captionColor = memoTheme.neutralSwatch.shade200;
    final captionStyle = Theme.of(context).textTheme.caption;

    return Text(progressDescription!, style: captionStyle?.copyWith(color: captionColor));
  }

  Widget _buildMemoryStabilityProgress() {
    final memoTheme = useTheme();
    final lineColor = memoTheme.secondarySwatch.shade400;

    return AnimatableLinearProgress(
      value: progressValue!,
      animationCurve: dimens.defaultAnimationCurve,
      animationDuration: dimens.defaultAnimatableProgressDuration,
      lineSize: dimens.collectionsLinearProgressLineWidth,
      lineColor: lineColor,
      lineBackgroundColor: memoTheme.neutralSwatch.shade900.withOpacity(0.4),
    );
  }
}

/// Custom background painter for a Card that represents a `Collection`
class _CollectionCardBackgroundPainter extends CustomPainter {
  _CollectionCardBackgroundPainter({required this.horizontalLineColor, required this.ovalGradientColors});

  final Color horizontalLineColor;
  final List<Color> ovalGradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    // Clip any additional drawings that exceed this bounds, like blurs
    canvas.clipRect(Offset.zero & size);

    _drawMultipleHorizontalLines(canvas, size);
    _drawOvalGradient(canvas, size);
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
          horizontalLineColor.withAlpha((255 * 0.03).round()), // 3% opacity
          horizontalLineColor.withAlpha((255 * 0.012).round()), // 1,2% opacity
          horizontalLineColor.withAlpha((255 * 0.03).round()) // 3% opacity
        ],
        [0, 0.5, 1],
      );

    // A horizontal line occurs every height+spacing points in height
    const repeatDistance = horizontalLineSpacing + horizontalLineHeight;
    final totalLines = (size.height / repeatDistance).truncate();
    for (var lineIndex = 0; lineIndex <= totalLines; lineIndex++) {
      final double dy = lineIndex * 3; // ignore: omit_local_variable_types

      // Keep drawing full-width horizontal lines in the y axis, respecting the `totalLines`
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), horizontalLinePaint);
    }
  }

  void _drawOvalGradient(Canvas canvas, Size size) {
    final ovalGradientPaint = Paint()
      ..blendMode = ui.BlendMode.hardLight
      // Makes the blur relative to the size's width, otherwise we might see some inconsistencies in "larger" elements
      ..maskFilter = ui.MaskFilter.blur(BlurStyle.normal, size.width)
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        ovalGradientColors,
      );

    // Draws a simple oval-shaped gradient that fits the whole size
    canvas.drawOval(Offset.zero & size, ovalGradientPaint);
  }

  @override
  bool shouldRepaint(covariant _CollectionCardBackgroundPainter oldDelegate) =>
      horizontalLineColor != oldDelegate.horizontalLineColor || ovalGradientColors != oldDelegate.ovalGradientColors;
}
