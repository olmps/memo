import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/core/faults/exceptions/url_exception.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Button themed for scenarios where its tap action links to some other resource (usually opening
/// external-to-the-application contents)
///
/// See also:
///   - [ExternalLinkButton] which already implements an URL handling.
class LinkButton extends HookWidget {
  const LinkButton({
    required this.onTap,
    required this.text,
    this.leading,
    this.trailing,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onTap;
  final String text;

  /// A leading widget that comes before the [text] element
  final Widget? leading;

  /// A trailing widget that comes after the [text] element
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final linkContents = Row(
      children: [
        if (leading != null) ...[
          leading!,
          context.horizontalBox(Spacing.small),
        ],
        Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis)),
        if (trailing != null) ...[
          context.horizontalBox(Spacing.small),
          trailing!,
        ],
      ],
    );

    final bgColor = useTheme().neutralSwatch.shade800;

    return Semantics(
      button: true,
      enabled: onTap != null,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimens.cardBorderWidth)),
        color: bgColor,
        child: InkWell(
          onTap: onTap,
          child: linkContents.withAllPadding(context, Spacing.medium),
        ),
      ),
    );
  }
}

/// List of allowed external links schemes
///
/// This could also accept `http`, `tel`, `mail` and `sms`, although we don't have a reason to allow those schemes.
const List<String> _allowedSchemes = ['https:'];

/// Component representing a button that opens an external (non-application scope) link
class ExternalLinkButton extends StatelessWidget {
  ExternalLinkButton(
    this.url, {
    this.isEnabled = true,
    this.description,
    this.leading,
    this.onFailLaunchingUrl,
    Key? key,
  }) : super(key: key) {
    _allowedSchemes.firstWhere((scheme) => url.toLowerCase().startsWith(scheme), orElse: () {
      throw InconsistentStateError.layout(
          'All links must start with one of the following schemes: $_allowedSchemes - actual: "$url"');
    });
  }

  final String url;
  final bool isEnabled;

  /// Overrides the [url] value as the [LinkButton.text] with a more descriptive text for this link
  final String? description;

  /// A leading widget that comes before the [url] (or [description] if present) element
  final Widget? leading;

  /// Callback that is triggered when the [url] has failed launching
  final void Function(URLException exception)? onFailLaunchingUrl;

  @override
  Widget build(BuildContext context) {
    const linkImage = AssetImage(images.linkAsset);
    const linkIcon = ImageIcon(linkImage, size: dimens.smallIconSize);

    return LinkButton(
      onTap: isEnabled ? _handleTap : null,
      text: description ?? url,
      leading: leading,
      trailing: linkIcon,
    );
  }

  Future<void> _handleTap() async {
    try {
      if (await url_launcher.canLaunch(url)) {
        await url_launcher.launch(url);
      } else {
        onFailLaunchingUrl?.call(URLException.failedToOpen());
      }
    } on PlatformException catch (exception) {
      final urlException = URLException.failedToOpen(debugInfo: exception.toString());
      onFailLaunchingUrl?.call(urlException);
    }
  }
}
