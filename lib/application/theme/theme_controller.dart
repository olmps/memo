import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/fonts.dart' as fonts;
import 'package:memo/application/theme/material_theme_data.dart' as material_theme;
import 'package:memo/application/theme/memo_theme_colors.dart' as colors;
import 'package:memo/application/theme/memo_theme_data.dart';

final themeController = StateNotifierProvider<ThemeController>((_) => ThemeController());

/// Provides management for all theme-related operations
///
/// This controller is responsible for notifying all listeners when its [StateNotifier.state] has been updated (usually
/// when [changeTheme] is called), so all dependencies can be rebuilt with the latest information about the theme.
///
/// See also:
///  - [MemoTheme] - enumerator defining all possible (but not necessarily available) themes;
///  - [MemoThemeData] - wrapper for all custom `ThemeData` properties.
class ThemeController extends StateNotifier<MemoThemeData> {
  ThemeController([MemoThemeData? value]) : super(value ?? _defaultThemeData);

  static const availableThemes = MemoTheme.values;

  @visibleForTesting
  static const defaultTheme = MemoTheme.classic;
  static final _defaultThemeData = MemoThemeData(
    defaultTheme,
    primarySwatch: _primarySwatchFor(MemoTheme.classic),
    secondarySwatch: _secondarySwatchFor(MemoTheme.classic),
    neutralSwatch: _neutralSwatchFor(MemoTheme.classic),
  );

  /// Updates the current [state] with a new instance of [MemoThemeData], using the [theme] argument
  ///
  /// If the [theme] argument is the same contained in the current state, nothing happens.
  void changeTheme(MemoTheme theme) {
    if (theme == state.theme) {
      return;
    }

    state = MemoThemeData(
      theme,
      primarySwatch: _primarySwatchFor(theme),
      secondarySwatch: _secondarySwatchFor(theme),
      neutralSwatch: _neutralSwatchFor(theme),
    );
  }

  /// Creates a `ThemeData` using the [context] and the current [state]
  ThemeData currentThemeData(BuildContext context) {
    final Color iconColor;
    final Color textColor;
    final Color bottomNavSelectedItemColor;

    switch (state.theme) {
      case MemoTheme.classic:
        iconColor = Colors.white;
        textColor = Colors.white;
        bottomNavSelectedItemColor = Colors.white;
        break;
    }

    final tabBarLabelPadding = context.symmetricInsets(vertical: Spacing.small);

    return material_theme.buildThemeData(
      // Theme material-related values
      textColor: textColor,
      iconColor: iconColor,
      bottomNavSelectedItemColor: bottomNavSelectedItemColor,
      // Text
      textThemeFontFamily: fonts.robotoMono,
      // Theme state swatches
      primarySwatch: state.primarySwatch,
      secondarySwatch: state.secondarySwatch,
      neutralSwatch: state.neutralSwatch,
      // Dimensions values
      roundedRectElementsRadius: dimens.genericRoundedElementBorderRadius,
      minButtonHeight: dimens.minButtonHeight,
      iconSize: dimens.iconSize,
      // Spacings values
      tabBarLabelPadding: tabBarLabelPadding,
    );
  }
}

/// Syntax sugar for _hooking_ the [themeController] state instance in a `HookWidget`
///
/// It's important to state that, just like any other `useProvider` call, the [useTheme] must also be called
/// directly in the `build` method of a `HookWidget`.
MemoThemeData useTheme() => useProvider(themeController.state);

/// Syntax sugar for _hooking_ the [themeController] provider instance in a `HookWidget`
///
/// It's important to state that, just like any other `useProvider` call, the [useThemeController] must also be called
/// directly in the `build` method of a `HookWidget`.
ThemeController useThemeController() => useProvider(themeController);

MaterialColor _primarySwatchFor(MemoTheme theme) {
  switch (theme) {
    case MemoTheme.classic:
      return colors.buildClassicPrimarySwatch();
  }
}

MaterialColor _secondarySwatchFor(MemoTheme theme) {
  switch (theme) {
    case MemoTheme.classic:
      return colors.buildClassicSecondarySwatch();
  }
}

MaterialColor _neutralSwatchFor(MemoTheme theme) {
  switch (theme) {
    case MemoTheme.classic:
      return colors.buildClassicNeutralSwatch();
  }
}
