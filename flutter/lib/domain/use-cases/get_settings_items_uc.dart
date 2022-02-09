abstract class GetSettingsItemsUC {
  List<SettingsItem> run();
}

class GetSettingsItemsImpl implements GetSettingsItemsUC {
  static const _items = {
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
      LinkSettingsItem(description: 'Discord', url: 'https://discord.gg/4DUSWdYwYD'),
    ],
    SettingsSection.organizers: [
      LinkSettingsItem(description: 'Lucas Montano', url: 'https://www.youtube.com/channel/UCyHOBY6IDZF9zOKJPou2Rgg'),
      LinkSettingsItem(description: 'Olympus', url: 'https://olmps.co/'),
    ],
  };

  @override
  List<SettingsItem> run() => _items.entries
      .map((entry) => [SettingsSectionItem(entry.key), ...entry.value])
      .expand((element) => element)
      .toList();
}

/// Available settings sections.
enum SettingsSection { legal, help, sponsors, community, organizers }

/// Named settings that links to external sources but have a locale-specific naming and url linking.
enum NamedLinkSettings { termsAndPrivacyPolicy, faq }

/// Named settings that have a locale-specific naming and custom navigation behavior.
enum NamedCustomSettings { licenses }

/// Base class of metadata related to a [SettingsSection].
abstract class SettingsItem {
  const SettingsItem();
}

class SettingsSectionItem extends SettingsItem {
  const SettingsSectionItem(this.section);

  final SettingsSection section;
}

abstract class SettingsContent extends SettingsItem {
  const SettingsContent();
}

/// Generic settings item that should open an external [url].
class LinkSettingsItem extends SettingsContent {
  const LinkSettingsItem({required this.description, required this.url});
  final String description;
  final String url;
}

class NamedLinkSettingsItem extends SettingsContent {
  const NamedLinkSettingsItem(this.linkSettings);
  final NamedLinkSettings linkSettings;
}

class NamedCustomSettingsItem extends SettingsContent {
  const NamedCustomSettingsItem(this.customSettings);
  final NamedCustomSettings customSettings;
}
