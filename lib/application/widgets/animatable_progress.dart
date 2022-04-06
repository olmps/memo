import 'dart:math';
import 'package:flutter/widgets.dart';

/// Min size reinforced in all progress indicators.
const _progressMinSize = 40.0;

/// Required interface to allow a [StatefulWidget] to use the [AnimatableProgressState].
abstract class AnimatableProgress extends StatefulWidget {
  const AnimatableProgress({Key? key}) : super(key: key);

  /// The initial value (of completeness) for this progress.
  ///
  /// The value must range betweeen `0.0` and `1.0`.
  double get value;

  /// The animation curve for any progress update made to this widget.
  Curve get animationCurve;

  /// The duration for the progress animation to complete.
  Duration get animationDuration;
}

/// Defines the required properties to draw a progress indicator.
abstract class ProgressPainter {
  /// The stroke width for both main progress line (and background if present).
  double get lineSize;

  /// Stroke color used to draw the main progress line.
  Color get lineColor;

  /// Optional stroke color used to draw the background progress line.
  Color? get lineBackgroundColor;
}

/// Generic state handling for all progress indicators.
///
/// This [State]:
///   - Animates to the initial value when its [initState] is called.
///   - Animates to the updated value when [didUpdateWidget] is called.
///   - Disposes the [animationController] when the implementing widget is also disposed (is `super.dispose` is called).
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

/// A customizable linear progress indicator.
///
/// An alternative to the `LinearProgressIndicator`, provided by the `flutter/material` framework, allowing further
/// customization that isn't provided by the material's components interfaces.
///
/// As an example to these customizations, the [AnimatableLinearProgress] uses a [CustomPainter] to draw itself, so it
/// can change the desired [StrokeCap] to the drawn progress lines.
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

  /// Label describing this widget - for accessibility.
  final String? semanticLabel;

  /// Constraints this linear progress width.
  final double? minWidth;

  @override
  AnimatableProgressState<AnimatableLinearProgress> createState() => _AnimatableLinearProgressState();
}

/// Implements the [AnimatableProgressState] for a linear-styled progress indicator.
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

/// Draws a linear progress with the specified arguments.
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
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2)));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineSize
      ..strokeCap = StrokeCap.round;

    // Instead of simply start from 0 up to until the endPoint, we have to make sure that our line starts drawing inside
    // the bounds (read more here https://github.com/flutter/flutter/issues/31202).
    final lineSizeOffset = lineSize / 2;

    final startPoint = Offset(lineSizeOffset, lineSizeOffset);
    if (lineBackgroundColor != null) {
      final endPoint = Offset(size.width - lineSizeOffset, lineSizeOffset);
      canvas.drawLine(startPoint, endPoint, paint..color = lineBackgroundColor!);
    }

    if (value > 0) {
      final endPoint = Offset((size.width * value) - lineSizeOffset, lineSizeOffset);
      canvas.drawLine(startPoint, endPoint, paint..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _LinearProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.lineSize != lineSize ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.lineBackgroundColor != lineBackgroundColor;
}

/// A customizable circular progress indicator.
///
/// An alternative to the `CircularProgressIndicator`, provided by the `flutter/material` framework, allowing further
/// customization that isn't provided by the material's components interfaces.
///
/// As an example to these customizations, the [AnimatableCircularProgress] uses a [CustomPainter] to draw itself, so it
/// can change the desired [StrokeCap] to the drawn progress lines.
class AnimatableCircularProgress extends AnimatableProgress implements ProgressPainter {
  const AnimatableCircularProgress({
    required this.value,
    required this.animationCurve,
    required this.animationDuration,
    required this.lineSize,
    required this.lineColor,
    this.semanticLabel,
    this.lineBackgroundColor,
    this.minSize,
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

  /// Label describing this widget - for accessibility.
  final String? semanticLabel;

  /// Constraints this circular progress size (both width and height).
  final double? minSize;

  @override
  AnimatableProgressState<AnimatableCircularProgress> createState() => _AnimatableCircularProgressState();
}

/// Implements the [AnimatableProgressState] for a circular-styled progress indicator.
class _AnimatableCircularProgressState extends AnimatableProgressState<AnimatableCircularProgress> {
  CustomPaint _progressPaintBuilder(BuildContext context, Widget? child) {
    return CustomPaint(
      painter: _CircularProgressPainter(
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
          minHeight: widget.minSize ?? _progressMinSize,
          minWidth: widget.minSize ?? _progressMinSize,
        ),
        child: AnimatedBuilder(
          animation: animationController,
          builder: _progressPaintBuilder,
        ),
      ),
    );
  }
}

/// Draws a circular progress with the specified arguments.
class _CircularProgressPainter extends CustomPainter implements ProgressPainter {
  const _CircularProgressPainter({
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

    if (lineBackgroundColor != null) {
      // Draw progress background stroke.
      canvas.drawArc(
        Offset.zero & size,
        _degreesToRadians(0),
        _degreesToRadians(360),
        false,
        paint..color = lineBackgroundColor!,
      );
    }

    if (value > 0) {
      // Draw progress stroke.
      canvas.drawArc(
        Offset.zero & size,
        _degreesToRadians(-90),
        _degreesToRadians(value * 360),
        false,
        paint..color = lineColor,
      );
    }
  }

  double _degreesToRadians(double degrees) => (pi / 180) * degrees;

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.lineSize != lineSize ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.lineBackgroundColor != lineBackgroundColor;
}
