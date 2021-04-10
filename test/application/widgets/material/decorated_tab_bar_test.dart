import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/material/decorated_tab_bar.dart';

import '../../../utils/widget_pump.dart';

void main() {
  testWidgets('DecoratedTabBar should render a bottom-positioned indicator', (tester) async {
    const fakeTabBar = TabBar(tabs: [Text('tab 1'), Text('tab 2')]);
    const fakeIndicatorHeight = 4.0;
    const wrappedDecoratedTab = DefaultTabController(
      length: 2,
      child: DecoratedTabBar(
        tabBar: fakeTabBar,
        indicatorHeight: fakeIndicatorHeight,
        indicatorColor: Colors.black,
      ),
    );

    await pumpMaterialScoped(tester, wrappedDecoratedTab);

    final bottomDividerFinder = find.byType(Container).first;
    final size = tester.getSize(bottomDividerFinder);
    final bottomLeftPosition = tester.getBottomRight(bottomDividerFinder);
    final bottomRightPosition = tester.getBottomRight(bottomDividerFinder);

    final parentFinder = find.byType(DecoratedTabBar).first;
    final bottomLeftParentPosition = tester.getBottomRight(parentFinder);
    final bottomRightParentPosition = tester.getBottomRight(parentFinder);

    // Has the same parent's bottom positions
    expect(bottomLeftPosition, bottomLeftParentPosition);
    expect(bottomRightPosition, bottomRightParentPosition);

    expect(size.height, fakeIndicatorHeight);
  });
}
