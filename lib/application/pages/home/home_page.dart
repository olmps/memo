import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/coordinator/routes_coordinator.dart';

enum HomeBottomTab { study, progress }

class HomePage extends StatelessWidget {
  const HomePage({required this.bottomTab, Key? key}) : super(key: key);

  final HomeBottomTab bottomTab;

  @override
  Widget build(BuildContext context) {
    final tabIndex = HomeBottomTab.values.indexOf(bottomTab);

    return Scaffold(
      appBar: _AppBar(bottomTab),
      // IndexedStack to retain each page state, more specifically, to preserving scrolling
      body: IndexedStack(
        index: tabIndex,
        children: [
          Scaffold(
            body: Container(),
          ),
          Scaffold(
            body: Container(),
          )
        ],
      ),
      bottomNavigationBar: _BottomAppBar(bottomTab),
    );
  }
}

// A custom app bar as `PreferredSizeWidget`, to conform to the requirements of a `Scaffold.appBar`
class _AppBar extends HookWidget implements PreferredSizeWidget {
  const _AppBar(this._tab);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final HomeBottomTab _tab;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_tab.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.read(coordinatorProvider).navigateToSettings();
          },
        ),
      ],
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar(this._tab);

  final HomeBottomTab _tab;

  @override
  Widget build(BuildContext context) {
    final tabItems = HomeBottomTab.values
        .map(
          (tab) => BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.title),
        )
        .toList();

    return BottomAppBar(
      child: BottomNavigationBar(
        onTap: (index) {
          switch (HomeBottomTab.values[index]) {
            case HomeBottomTab.study:
              context.read(coordinatorProvider).navigateToStudy();
              break;
            case HomeBottomTab.progress:
              context.read(coordinatorProvider).navigateToProgress();
              break;
          }
        },
        currentIndex: HomeBottomTab.values.indexOf(_tab),
        items: tabItems,
      ),
    );
  }
}

extension _TabMetadata on HomeBottomTab {
  String get title {
    switch (this) {
      case HomeBottomTab.study:
        return 'Study';
      case HomeBottomTab.progress:
        return 'Progress';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeBottomTab.study:
        return Icons.folder_open;
      case HomeBottomTab.progress:
        return Icons.arrow_upward;
    }
  }
}
