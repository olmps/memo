import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsVM = Provider((_) => SettingsVM());

class SettingsVM {
  SettingsVM()
      : items = _items.entries
            .map((entry) => [SettingsSectionItem(entry.key), ...entry.value])
            .expand((element) => element)
            .toList();

  final List<SettingsItem> items;
}

const _items = {
  SettingsSection.legal: [
    NamedLinkSettingsItem(NamedLinkSettings.termsAndPrivacyPolicy),
    NamedCustomSettingsItem(NamedCustomSettings.licenses),
  ],
  SettingsSection.help: [
    NamedLinkSettingsItem(NamedLinkSettings.faq),
  ],
  SettingsSection.sponsors: [
    LinkSettingsItem(description: 'Rocketseat', url: 'https://rocketseat.com.br/'),
    LinkSettingsItem(description: 'Startup Life', url: 'https://startuplife.com.br/'),
    LinkSettingsItem(description: 'Pingback', url: 'https://pingback.com/about'),
  ],
  SettingsSection.community: [
    LinkSettingsItem(description: 'Discord', url: 'https://discord.gg/E9eHrpA2'),
  ],
  SettingsSection.organizers: [
    LinkSettingsItem(description: 'Lucas Montano', url: 'https://www.youtube.com/channel/UCyHOBY6IDZF9zOKJPou2Rgg'),
    LinkSettingsItem(description: 'Olympus', url: 'https://olmps.co/'),
  ],
};

/// Base class to be implemented by any metadata related to a [SettingsSection]
///
/// The purpose of this class and its subclasses are only to make the UI work easier and more agnostic to any possible
/// logic, being responsible solely for rendering the layout given each metadata.
abstract class SettingsItem extends Equatable {
  const SettingsItem();
}

/// Available settings sections
enum SettingsSection { legal, help, sponsors, community, organizers }

/// Named settings that links to external sources but have a locale-specific naming and url linking
enum NamedLinkSettings { termsAndPrivacyPolicy, faq }

/// Named settings that have a locale-specific naming and custom navigation behavior
enum NamedCustomSettings { licenses }

class SettingsSectionItem extends SettingsItem {
  const SettingsSectionItem(this.section);

  final SettingsSection section;

  @override
  List<Object?> get props => [section];
}

abstract class SettingsContent extends SettingsItem {
  const SettingsContent();
}

/// Generic settings item that should open an external [url]
class LinkSettingsItem extends SettingsContent {
  const LinkSettingsItem({required this.description, required this.url});
  final String description;
  final String url;

  @override
  List<Object?> get props => [description, url];
}

class NamedLinkSettingsItem extends SettingsContent {
  const NamedLinkSettingsItem(this.linkSettings);
  final NamedLinkSettings linkSettings;

  @override
  List<Object?> get props => [linkSettings];
}

class NamedCustomSettingsItem extends SettingsContent {
  const NamedCustomSettingsItem(this.customSettings);
  final NamedCustomSettings customSettings;

  @override
  List<Object?> get props => [customSettings];
}
