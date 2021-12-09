import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/animatable_progress.dart';

import '../../utils/widget_pump.dart';

class FakeAnimatableProgress extends AnimatableProgress {
  const FakeAnimatableProgress(this.value);
  @override
  FakeAnimatableProgressState createState() => FakeAnimatableProgressState();

  @override
  final double value;

  @override
  Curve get animationCurve => Curves.linear;

  @override
  Duration get animationDuration => Duration.zero;
}

class FakeAnimatableProgressState extends AnimatableProgressState<FakeAnimatableProgress> {
  @override
  Widget build(BuildContext context) => Container();
}

void main() {
  group('AnimatableProgressState -', () {
    testWidgets('should update its animation value when a new value is passed', (tester) async {
      final finder = find.byType(FakeAnimatableProgress).first;

      var progressValue = 0.5;
      final fakeProgress = FakeAnimatableProgress(progressValue);
      await pumpMaterialScoped(tester, fakeProgress);
      final initialState = tester.state<AnimatableProgressState>(finder);
      expect(initialState.animationController.value, progressValue);

      progressValue = 1;
      final updatedFakeProgress = FakeAnimatableProgress(progressValue);
      await pumpMaterialScoped(tester, updatedFakeProgress);
      final updatedState = tester.state<AnimatableProgressState>(finder);
      expect(updatedState.animationController.value, progressValue);
    });

    testWidgets('should clamp out of bounds value updates', (tester) async {
      final finder = find.byType(FakeAnimatableProgress).first;

      var progressValue = 0.5;
      var fakeProgress = FakeAnimatableProgress(progressValue);
      await pumpMaterialScoped(tester, fakeProgress);
      final initialState = tester.state<AnimatableProgressState>(finder);
      expect(initialState.animationController.value, progressValue);

      progressValue = 2;
      fakeProgress = FakeAnimatableProgress(progressValue);
      await pumpMaterialScoped(tester, fakeProgress);
      final upperBoundState = tester.state<AnimatableProgressState>(finder);
      expect(upperBoundState.animationController.value, 1);

      progressValue = -1;
      fakeProgress = FakeAnimatableProgress(progressValue);
      await pumpMaterialScoped(tester, fakeProgress);
      final lowerBoundState = tester.state<AnimatableProgressState>(finder);
      expect(lowerBoundState.animationController.value, 0);
    });
  });

  group('AnimatableLinearProgress -', () {
    testWidgets('should respect its minimum width', (tester) async {
      const fakeWidth = 100.0;
      const fakeLineSize = 10.0;
      const fakeProgress = AnimatableLinearProgress(
        value: 0,
        animationCurve: Curves.linear,
        animationDuration: Duration.zero,
        lineColor: Color.fromRGBO(0, 0, 0, 0),
        lineSize: fakeLineSize,
        minWidth: fakeWidth,
      );

      await pumpMaterialScoped(tester, fakeProgress);

      final finder = find.byType(AnimatableLinearProgress).first;
      final size = tester.getSize(finder);
      expect(size, const Size(fakeWidth, fakeLineSize));
    });
  });

  group('AnimatableCircularProgress -', () {
    testWidgets('should respect its minimum size', (tester) async {
      const fakeSize = 100.0;
      const fakeLineSize = 10.0;
      const fakeProgress = AnimatableCircularProgress(
        value: 0,
        animationCurve: Curves.linear,
        animationDuration: Duration.zero,
        lineColor: Color.fromRGBO(0, 0, 0, 0),
        lineSize: fakeLineSize,
        minSize: fakeSize,
      );

      await pumpMaterialScoped(tester, fakeProgress);

      final finder = find.byType(AnimatableCircularProgress).first;
      final size = tester.getSize(finder);
      expect(size, const Size.square(fakeSize));
    });
  });
}
