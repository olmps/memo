import 'package:flutter/material.dart';

/// Decorates a [TabBar] with custom layout specs
class DecoratedTabBar extends StatelessWidget {
  const DecoratedTabBar({
    required this.tabBar,
    required this.indicatorHeight,
    required this.indicatorColor,
    Key? key,
  }) : super(key: key);

  final TabBar tabBar;

  /// Height for the bottom indicator line that crosses element's width
  final double indicatorHeight;

  /// Color for the bottom indicator line that crosses element's width
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    final bottomInsetBorder = Container(height: indicatorHeight, color: indicatorColor);
    return Stack(
      children: [
        Positioned(bottom: 0, left: 0, right: 0, child: bottomInsetBorder),
        tabBar,
      ],
    );
  }
}
