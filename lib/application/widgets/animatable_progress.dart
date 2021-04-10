import 'dart:math';
import 'package:flutter/widgets.dart';

/// Min size reinforced in all progress indicators
const _progressMinSize = 40.0;

/// Required interface to allow a [StatefulWidget] to hold a [_AnimatableProgressState]
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
abstract class _AnimatableProgressState<T extends AnimatableProgress> extends State<T>
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
