import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/widgets/theme/themed_tab_bar.dart';

import '../../../utils/widget_pump.dart';

void main() {
  testWidgets('ThemedTabBar should render a bottom-positioned indicator', (tester) async {
    await pumpMaterialScoped(
      tester,
      ProviderScope(
        child: HookBuilder(
          builder: (context) {
            final fakeController = useTabController(initialLength: 2);
            return ThemedTabBar(
              controller: fakeController,
              tabs: const [Text('tab 1'), Text('tab 2')],
            );
          },
        ),
      ),
    );

    final bottomDividerFinder = find.byType(Container).first;
    final size = tester.getSize(bottomDividerFinder);
    final bottomLeftPosition = tester.getBottomLeft(bottomDividerFinder);
    final bottomRightPosition = tester.getBottomRight(bottomDividerFinder);

    final parentFinder = find.byType(ThemedTabBar).first;
    final bottomLeftParentPosition = tester.getBottomLeft(parentFinder);
    final bottomRightParentPosition = tester.getBottomRight(parentFinder);

    // Has the same parent's bottom positions
    expect(bottomLeftPosition, bottomLeftParentPosition);
    expect(bottomRightPosition, bottomRightParentPosition);

    expect(size.height, dimens.genericBorderHeight);
  });
}
