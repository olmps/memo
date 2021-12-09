import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/scaffold_messenger.dart';
import 'package:memo/application/view-models/settings/settings_vm.dart';
import 'package:memo/application/widgets/theme/link.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

class SettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(settingsVM).items;
    final licenseBg = ref.watch(themeController).neutralSwatch.shade900;

    return Scaffold(
      appBar: AppBar(title: const Text(strings.settings)),
      body: ListView.builder(
        padding: EdgeInsets.only(bottom: context.rawSpacing(Spacing.xLarge)),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          if (item is SettingsSectionItem) {
            return Text(
              strings.settingsDescriptionForSection(item.section),
              style: Theme.of(context).textTheme.subtitle1,
            ).withOnlyPadding(context, top: Spacing.xLarge, bottom: Spacing.xxSmall);
          } else if (item is LinkSettingsItem) {
            return UrlLinkButton(
              item.url,
              text: item.description,
              onFailLaunchingUrl: (exception) => showExceptionSnackBar(ref, exception),
            ).withOnlyPadding(context, top: Spacing.xSmall);
          } else if (item is NamedLinkSettingsItem) {
            return UrlLinkButton(
              strings.settingsUrlForNamedLink(item.linkSettings),
              text: strings.settingsDescriptionForNamedLink(item.linkSettings),
              onFailLaunchingUrl: (exception) => showExceptionSnackBar(ref, exception),
            ).withOnlyPadding(context, top: Spacing.xSmall);
          } else if (item is NamedCustomSettingsItem) {
            final navigationImage = AssetImage(images.chevronRightAsset);
            final navigationIcon = ImageIcon(navigationImage, size: dimens.smallIconSize);

            return LinkButton(
              onTap: () {
                switch (item.customSettings) {
                  case NamedCustomSettings.licenses:
                    _navigateToLicense(context, licensePageBackgroundColor: licenseBg);
                    break;
                }
              },
              trailing: navigationIcon,
              text: strings.settingsDescriptionForNamedCustom(item.customSettings),
            ).withOnlyPadding(context, top: Spacing.xSmall);
          }

          throw InconsistentStateError.layout('Unsupported subtype (${item.runtimeType}) of `SettingsItem`');
        },
      ).withSymmetricalPadding(context, horizontal: Spacing.medium),
    );
  }

  void _navigateToLicense(BuildContext context, {required Color licensePageBackgroundColor}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Theme(
          // `cardColor` is used by the LicensePage to draw its background color.
          data: Theme.of(context).copyWith(cardColor: licensePageBackgroundColor),
          child: const LicensePage(),
        ),
      ),
    );
  }
}
