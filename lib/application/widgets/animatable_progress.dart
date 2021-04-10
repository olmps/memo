import 'dart:math';
import 'package:flutter/widgets.dart';

/// Min size reinforced in all progress indicators
const _progressMinSize = 40.0;

/// Required interface to allow a [StatefulWidget] to hold a [AnimatableProgressState]
abstract class AnimatableProgress extends StatefulWidget {
  const AnimatableProgress({Key? key}) : super(key: key);

  /// The initial value (of completeness) for this progress
  ///
  /// The value must range betweeen `0.0` and `1.0`.
  double get value;

  /// The animation curve for any progress update made to this widget
  Curve get animationCurve;

  /// The duration for the progress animation to complete
  Duration get animationDuration;
}

/// Defines the required properties to draw a progress indicator
abstract class ProgressPainter {
  /// The stroke width for both main progress line (and background if present)
  double get lineSize;

  /// Stroke color used to draw the main progress line
  Color get lineColor;

  /// Optional stroke color used to draw the background progress line
  Color? get lineBackgroundColor;
}

/// Generic state handling of all progress indicators
///
/// This [State] works as following:
///   - Animate to the initial value when its [initState] is called;
///   - Animates to the updated value when [didUpdateWidget] is called;
///   - Dispose of the [animationController] when the implementing widget is also disposed.
@visibleForTesting
abstract class AnimatableProgressState<T extends AnimatableProgress> extends State<T>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  String get semanticProgressValue => '${(widget.value * 100).round()}%';

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    animationController.animateTo(widget.value, curve: widget.animationCurve, duration: widget.animationDuration);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) {
      return;
    }

    animationController.animateTo(widget.value, curve: widget.animationCurve, duration: widget.animationDuration);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

/// A customizable linear progress indicator
///
/// This component is an alternative to the `LinearProgressIndicator`, provided by the `flutter/material` framework.
/// It allows further customization that isn't provided  by the material's components interfaces.
///
/// To exemplify the customizations, the [AnimatableLinearProgress] uses a [CustomPainter] to draw itself, so it can
/// change the desired [StrokeCap] to the drawn progress lines (which is something we can't achieve if using the
/// material one).
class AnimatableLinearProgress extends AnimatableProgress implements ProgressPainter {
  const AnimatableLinearProgress({
    required this.value,
    required this.animationCurve,
    required this.animationDuration,
    required this.lineSize,
    required this.lineColor,
    this.semanticLabel,
    this.lineBackgroundColor,
    this.minWidth,
    Key? key,
  }) : super(key: key);

  @override
  final double value;

  @override
  final Curve animationCurve;

  @override
  final Duration animationDuration;

  @override
  final Color? lineBackgroundColor;

  @override
  final Color lineColor;

  @override
  final double lineSize;

  /// Label describing this widget - for accessibility concerns
  final String? semanticLabel;

  /// Constraints this linear progress width
  final double? minWidth;

  @override
  _AnimatableLinearProgressState createState() => _AnimatableLinearProgressState();
}

/// Implements the [AnimatableProgressState] for a linear-styled progress indicator
class _AnimatableLinearProgressState extends AnimatableProgressState<AnimatableLinearProgress> {
  CustomPaint _progressPaintBuilder(BuildContext context, Widget? child) {
    return CustomPaint(
      painter: _LinearProgressPainter(
        value: animationController.value,
        lineSize: widget.lineSize,
        lineColor: widget.lineColor,
        lineBackgroundColor: widget.lineBackgroundColor,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      value: semanticProgressValue,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth ?? _progressMinSize,
          minHeight: widget.lineSize,
        ),
        child: AnimatedBuilder(
          animation: animationController,
          builder: _progressPaintBuilder,
        ),
      ),
    );
  }
}

/// Draws a linear progress with the specified arguments
class _LinearProgressPainter extends CustomPainter implements ProgressPainter {
  const _LinearProgressPainter({
    required this.value,
    required this.lineSize,
    required this.lineColor,
    this.lineBackgroundColor,
  }) : assert(value >= 0 && value <= 1);

  final double value;

  @override
  final Color? lineBackgroundColor;

  @override
  final Color lineColor;

  @override
  final double lineSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineSize
      ..strokeCap = StrokeCap.round;

    if (value > 0) {
      canvas.drawLine(Offset.zero, Offset(size.width * value, 0), paint..color = lineColor);
    }

    if (lineBackgroundColor != null) {
      canvas.drawLine(Offset.zero, Offset(size.width, 0), paint..color = lineBackgroundColor!);
    }
  }

  @override
  bool shouldRepaint(covariant _LinearProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.lineSize != lineSize ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.lineBackgroundColor != lineBackgroundColor;
}
