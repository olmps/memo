import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';

class UpdateCollectionMemos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CreateMemoEmptyState(
      onTap: () {
        // TODO(ggirotto): Connect with the VM when available
      },
    );
  }
}

/// An empty state call-to-action to add a new `Memo` to its `Collection`.
class _CreateMemoEmptyState extends ConsumerWidget {
  const _CreateMemoEmptyState({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;

    final roundedPlusIcon = CustomPaint(
      size: const Size(dimens.createMemoCtaSide, dimens.createMemoCtaSide),
      painter: _CreateButtonPainter(
        backgroundColor: theme.primarySwatch.shade400,
        createColor: theme.neutralSwatch.shade800,
      ),
    );

    final createMemoCta = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        roundedPlusIcon,
        context.verticalBox(Spacing.small),
        Text(
          strings.newMemo.toUpperCase(),
          style: textTheme.button?.copyWith(color: theme.primarySwatch.shade400),
          textAlign: TextAlign.center,
        )
      ],
    );

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: theme.neutralSwatch.shade700, width: dimens.genericBorderHeight),
            borderRadius: dimens.executionsTerminalBorderRadius,
            color: theme.neutralSwatch.shade800,
          ),
          child: Center(child: createMemoCta),
        ),
      ),
    );
  }
}

class _CreateButtonPainter extends CustomPainter {
  _CreateButtonPainter({required this.backgroundColor, required this.createColor});

  final Color backgroundColor;
  final Color createColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);

    final backgroundCircle = Path()
      ..addOval(
        Rect.fromCircle(
          center: bounds.center,
          radius: bounds.height / 2,
        ),
      );

    canvas.drawPath(backgroundCircle, backgroundPaint);

    final stripsPainter = Paint()
      ..color = createColor
      ..strokeWidth = dimens.createMemoCtaButtonStrokeWidth
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final xCenter = size.width / 2;
    final yCenter = size.height / 2;

    final xQuarter = size.width / 3.5;
    final yQuarter = size.height / 3.5;

    canvas
      ..drawLine(Offset(xCenter, yQuarter), Offset(xCenter, size.height - yQuarter), stripsPainter)
      ..drawLine(Offset(xQuarter, yCenter), Offset(size.width - xQuarter, yCenter), stripsPainter);
  }

  @override
  bool shouldRepaint(_CreateButtonPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor || createColor != oldDelegate.createColor;
}
