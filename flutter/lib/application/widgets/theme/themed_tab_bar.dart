import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';

/// Decorates a [TabBar] with custom layout specs.
class ThemedTabBar extends ConsumerWidget {
  const ThemedTabBar({required this.controller, required this.tabs, Key? key}) : super(key: key);

  final TabController controller;
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoTheme = ref.watch(themeController);
    final selectedColor = memoTheme.secondarySwatch.shade400;
    final unselectedColor = memoTheme.neutralSwatch.shade700;
    const borderHeight = dimens.genericBorderHeight;

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
