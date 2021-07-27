import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';

/// Decorates a [TabBar] with custom layout specs.
class ThemedTabBar extends HookWidget {
  const ThemedTabBar({required this.controller, required this.tabs, Key? key}) : super(key: key);

  final TabController controller;
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final memoTheme = useTheme();
    final selectedColor = memoTheme.secondarySwatch.shade400;
    final unselectedColor = memoTheme.neutralSwatch.shade700;
    const borderHeight = dimens.tabBarBorderHeight;

    final tabBar = TabBar(
      controller: controller,
      tabs: tabs,
      indicatorWeight: borderHeight * 2,
      indicatorColor: selectedColor,
    );

    /// Bottom indicator line that crosses the full element's width.
    final bottomInsetBorder = Container(height: borderHeight, color: unselectedColor);
    return Stack(
      children: [
        Positioned(bottom: 0, left: 0, right: 0, child: bottomInsetBorder),
        tabBar,
      ],
    );
  }
}
