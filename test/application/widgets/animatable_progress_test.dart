import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/animatable_progress.dart';

import '../../utils/widget_pump.dart';

void main() {
  AnimatableLinearProgress buildFakeLinearProgress({
    double value = 0,
    double fakeWidth = 40,
    double fakeLineSize = 4,
  }) {
    return AnimatableLinearProgress(
      value: value,
      animationCurve: Curves.linear,
      animationDuration: Duration.zero,
      lineColor: const Color.fromRGBO(0, 0, 0, 0),
      lineSize: fakeLineSize,
      minWidth: fakeWidth,
    );
  }

  testWidgets('AnimatableLinearProgress should respect its minimum width', (tester) async {
    const fakeWidth = 100.0;
    const fakeLineSize = 10.0;
    final fakeProgress = buildFakeLinearProgress(fakeWidth: fakeWidth, fakeLineSize: fakeLineSize);

    await pumpMaterialScoped(tester, fakeProgress);

    final finder = find.byType(AnimatableLinearProgress).first;
    final size = tester.getSize(finder);
    expect(size, const Size(fakeWidth, fakeLineSize));
  });

  testWidgets(
    'AnimatableLinearProgress should update its animation value when a new value is passed',
    (tester) async {
      var progressValue = 0.5;
      final fakeProgress = buildFakeLinearProgress(value: progressValue);
      await pumpMaterialScoped(tester, fakeProgress);

      final finder = find.byType(AnimatableLinearProgress).first;
      final initialState = tester.state<AnimatableProgressState>(finder);
      expect(initialState.animationController.value, progressValue);

      progressValue = 1;
      final updatedFakeProgress = buildFakeLinearProgress(value: progressValue);
      await pumpMaterialScoped(tester, updatedFakeProgress);

      final updatedState = tester.state<AnimatableProgressState>(finder);
      expect(updatedState.animationController.value, progressValue);
    },
  );

  testWidgets(
    'AnimatableLinearProgress should clamp out of bounds value updates',
    (tester) async {
      final finder = find.byType(AnimatableLinearProgress).first;

      var progressValue = 0.5;
      var fakeProgress = buildFakeLinearProgress(value: progressValue);
      await pumpMaterialScoped(tester, fakeProgress);
      final initialState = tester.state<AnimatableProgressState>(finder);
      expect(initialState.animationController.value, progressValue);

      progressValue = 2;
      fakeProgress = buildFakeLinearProgress(value: progressValue);
      await pumpMaterialScoped(tester, fakeProgress);
      final upperBoundState = tester.state<AnimatableProgressState>(finder);
      expect(upperBoundState.animationController.value, 1);

      progressValue = -1;
      fakeProgress = buildFakeLinearProgress(value: progressValue);
      await pumpMaterialScoped(tester, fakeProgress);
      final lowerBoundState = tester.state<AnimatableProgressState>(finder);
      expect(lowerBoundState.animationController.value, 0);
    },
  );
}
