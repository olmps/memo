import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/core/faults/exceptions/url_exception.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Decorates a text link, themed like a button, with custom layout specs.
class LinkButton extends ConsumerWidget {
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

  /// A widget that is displayed before the [text] element.
  final Widget? leading;

  /// A widget that is displayed after the [text] element.
  final Widget? trailing;

  /// Overrides the default `backgroundColor`.
  final Color? backgroundColor;

  /// Overrides the default text's `textStyle`.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final themeColor = ref.watch(themeController).neutralSwatch.shade800;

    return Semantics(
      button: true,
      enabled: onTap != null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(dimens.cardBorderWidth),
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
      ),
    );
  }
}

/// List of allowed external links schemes
///
/// This could also accept `http`, `tel`, `mail` and `sms`, although we don't have a reason to allow those schemes.
const List<String> _allowedSchemes = ['https:'];

/// Decorates an URL text link themed like a button, with custom layout specs.
///
/// Pressing this widget will open the [url] using the respective platform's browser, when [isEnabled] is set to `true`
/// (default).
class UrlLinkButton extends StatelessWidget {
  UrlLinkButton(
    this.url, {
    this.isEnabled = true,
    this.leading,
    this.onFailLaunchingUrl,
    this.text,
    this.backgroundColor,
    this.textStyle,
    Key? key,
  }) : super(key: key) {
    _allowedSchemes.firstWhere(
      (scheme) => url.toLowerCase().startsWith(scheme),
      orElse: () {
        throw InconsistentStateError.layout(
          'All links must start with one of the following schemes: $_allowedSchemes - actual: "$url"',
        );
      },
    );
  }

  final String url;
  final bool isEnabled;

  /// A widget that is displayed before the [url] (or [text] if present) element.
  final Widget? leading;

  /// Callback that is triggered when [url] has failed launching.
  final void Function(UrlException exception)? onFailLaunchingUrl;

  /// Overrides the displaying link's text [url] value with this value.
  final String? text;

  /// Overrides the default `backgroundColor`.
  final Color? backgroundColor;

  /// Overrides the default text's `textStyle`.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final linkImage = AssetImage(images.linkAsset);
    final linkIcon = ImageIcon(linkImage, size: dimens.smallIconSize);

    return LinkButton(
      onTap: isEnabled ? () => _handleUrlLaunch(url, onFailLaunchingUrl) : null,
      text: text ?? url,
      leading: leading,
      trailing: linkIcon,
      textStyle: textStyle,
      backgroundColor: backgroundColor,
    );
  }
}

/// Decorates an URL text link themed like an underlined text, with custom layout specs.
///
/// Pressing this widget will open the [url] using the respective platform's browser, when [isEnabled] is set to `true`
/// (default).
class UnderlinedUrlLink extends ConsumerWidget {
  UnderlinedUrlLink(
    this.url, {
    this.isEnabled = true,
    this.text,
    this.onFailLaunchingUrl,
    Key? key,
  }) : super(key: key) {
    _allowedSchemes.firstWhere(
      (scheme) => url.toLowerCase().startsWith(scheme),
      orElse: () {
        throw InconsistentStateError.layout(
          'All links must start with one of the following schemes: $_allowedSchemes - actual: "$url"',
        );
      },
    );
  }

  final String url;
  final bool isEnabled;

  /// Overrides the displaying link's text [url] value with this value.
  final String? text;

  /// Callback that is triggered when [url] has failed launching.
  final void Function(UrlException exception)? onFailLaunchingUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      enabled: isEnabled,
      child: InkWell(
        onTap: isEnabled ? () => _handleUrlLaunch(url, onFailLaunchingUrl) : null,
        child: Text(
          text ?? url,
          style: Theme.of(context).textTheme.caption?.copyWith(
                color: ref.watch(themeController).neutralSwatch.shade300,
                decoration: TextDecoration.underline,
              ),
        ),
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
