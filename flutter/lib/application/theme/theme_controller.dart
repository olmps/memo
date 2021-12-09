import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/fonts.dart' as fonts;
import 'package:memo/application/theme/material_theme_data.dart' as material_theme;
import 'package:memo/application/theme/memo_theme_colors.dart' as colors;
import 'package:memo/application/theme/memo_theme_data.dart';

final themeController = StateNotifierProvider<ThemeController, MemoThemeData>((_) => ThemeController());

/// Controls theme-related operations.
///
/// Responsible for notifying all listeners when its [StateNotifier.state] has been updated (usually when [changeTheme]
/// is called), so all dependencies can be rebuilt with the latest information about the theme.
///
/// See also:
///  - [MemoTheme], enumerator defining all possible (but not necessarily in [availableThemes]) themes.
///  - [MemoThemeData], wrapper for all custom theme properties.
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
    destructiveSwatch: _destructiveSwatchFor(MemoTheme.classic),
  );

  /// Updates the current [state] with a new instance of [MemoThemeData], using the [theme] argument.
  ///
  /// If [theme] is the same as the current state, does nothing.
  void changeTheme(MemoTheme theme) {
    if (theme == state.theme) {
      return;
    }

    state = MemoThemeData(
      theme,
      primarySwatch: _primarySwatchFor(theme),
      secondarySwatch: _secondarySwatchFor(theme),
      neutralSwatch: _neutralSwatchFor(theme),
      destructiveSwatch: _destructiveSwatchFor(theme),
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
    final textFieldPadding = context.symmetricInsets(horizontal: Spacing.small, vertical: Spacing.xSmall);

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
      destructiveSwatch: state.destructiveSwatch,
      // Dimensions values
      roundedRectElementsRadius: dimens.genericRoundedElementBorderRadius,
      minButtonHeight: dimens.minButtonHeight,
      iconSize: dimens.iconSize,
      // Spacings values
      tabBarLabelPadding: tabBarLabelPadding,
      textFieldPadding: textFieldPadding,
    );
  }
}

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

MaterialColor _destructiveSwatchFor(MemoTheme theme) {
  switch (theme) {
    case MemoTheme.classic:
      return colors.buildClassicDestructiveSwatch();
  }
}
