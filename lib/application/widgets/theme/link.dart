import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/theme/theme_controller.dart';
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
    this.backgroundColor,
    this.textStyle,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onTap;
  final String text;

  /// A leading widget that comes before the [text] element
  final Widget? leading;

  /// A trailing widget that comes after the [text] element
  final Widget? trailing;

  /// Overrides the default theme backgroundColor
  final Color? backgroundColor;

  /// Overrides the default text style
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final linkContents = Row(
      children: [
        if (leading != null) ...[
          leading!,
          context.horizontalBox(Spacing.small),
        ],
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        if (trailing != null) ...[
          context.horizontalBox(Spacing.small),
          trailing!,
        ],
      ],
    );

    final themeColor = useTheme().neutralSwatch.shade800;

    return Semantics(
      button: true,
      enabled: onTap != null,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimens.cardBorderWidth),
          side: BorderSide(color: themeColor),
        ),
        color: backgroundColor ?? themeColor,
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

/// A custom-layout button that opens an external (non-application scope) link
///
/// See also:
///   - [ExternalLinkTextButton] for simpler use-cases that only require a text button.
class ExternalLinkButton extends StatelessWidget {
  ExternalLinkButton(
    this.url, {
    this.isEnabled = true,
    this.description,
    this.leading,
    this.onFailLaunchingUrl,
    this.backgroundColor,
    this.textStyle,
    this.iconColor,
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

  /// Overrides the default theme backgroundColor
  final Color? backgroundColor;

  /// The trailing icon color
  final Color? iconColor;

  /// The description text style
  final TextStyle? textStyle;

  /// Callback that is triggered when the [url] has failed launching
  final void Function(UrlException exception)? onFailLaunchingUrl;

  @override
  Widget build(BuildContext context) {
    final linkImage = AssetImage(images.linkAsset);
    final linkIcon = ImageIcon(
      linkImage,
      size: dimens.smallIconSize,
      color: iconColor,
    );

    return LinkButton(
      onTap: isEnabled ? () => _handleUrlLaunch(url, onFailLaunchingUrl) : null,
      text: description ?? url,
      leading: leading,
      trailing: linkIcon,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
    );
  }
}

/// A custom-layout text button that opens an external (non-application scope) link
///
/// See also:
///   - [ExternalLinkButton] for use-cases that required a more emphatic button action.
class ExternalLinkTextButton extends HookWidget {
  ExternalLinkTextButton(
    this.url, {
    this.text,
    this.onFailLaunchingUrl,
    Key? key,
  }) : super(key: key) {
    _allowedSchemes.firstWhere((scheme) => url.toLowerCase().startsWith(scheme), orElse: () {
      throw InconsistentStateError.layout(
          'All links must start with one of the following schemes: $_allowedSchemes - actual: "$url"');
    });
  }

  final String url;

  /// Overrides the [url] value as the text for this widget, usually with a more descriptive text for the [url]
  final String? text;

  /// Callback that is triggered when the [url] has failed launching
  final void Function(UrlException exception)? onFailLaunchingUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleUrlLaunch(url, onFailLaunchingUrl),
      child: Text(
        text ?? url,
        style: Theme.of(context)
            .textTheme
            .caption
            ?.copyWith(color: useTheme().neutralSwatch.shade300, decoration: TextDecoration.underline),
      ),
    );
  }
}

Future<void> _handleUrlLaunch(String url, Function(UrlException exception)? onFailLaunchingUrl) async {
  try {
    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);
    } else {
      onFailLaunchingUrl?.call(UrlException.failedToOpen(debugInfo: url));
    }
  } on PlatformException catch (exception) {
    final urlException = UrlException.failedToOpen(debugInfo: exception.toString());
    onFailLaunchingUrl?.call(urlException);
  }
}
