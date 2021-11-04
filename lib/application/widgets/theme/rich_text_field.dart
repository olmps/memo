import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/bottom_sheet.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/themed_container.dart';
import 'package:tuple/tuple.dart';

/// A [TextField] variation that supports rich text content.
///
/// The field supports rich text content by opening a modal when tapped with an embedded `Quill Editor`.
///
/// The field also supports presenting rich text content, different from [TextField] which only supports simple
/// text content. The field content height is limited by [dimens.richTextFieldConstraints].
class RichTextField extends HookWidget {
  const RichTextField({required this.title, required this.placeholder, this.controller});

  /// The modal title positioned in the top-left corner of the modal editor.
  final Widget title;

  /// The placeholder used in the rich text editor when it has no content.
  final String placeholder;

  /// Controls the text content being edited.
  final RichTextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final textTheme = Theme.of(context).textTheme;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    final initialText = '${controller?.richTextContent ?? ''}\n';
    final initialController = quill.QuillController(
      document: quill.Document.fromDelta(quill.Delta()..insert(initialText)),
      selection: const TextSelection.collapsed(offset: 0),
    );
    // Holds the entire field `quill` controller which is later replaced by `modalEditorController`, since it's not
    // possible to forward the content from one controller to another.
    final richFieldController = useState(initialController);

    Future<void> showRichTextFieldModal() async {
      final modalEditorController = quill.QuillController(
        document: richFieldController.value.document,
        selection: richFieldController.value.selection,
      );

      await showSnappableDraggableModalBottomSheet<void>(
        context,
        child: RichTextFieldModal(title: title, controller: modalEditorController, placeholder: placeholder),
      );

      controller?.update(jsonEncode(modalEditorController.document.toDelta().toJson()));
      richFieldController.value = modalEditorController;
    }

    final content = richFieldController.value.plainTextEditingValue.text;
    // `quill` automatically adds `\n` when initializing the editor without content
    final hasContent = content.isNotEmpty && content != '\n';

    return GestureDetector(
      onTap: showRichTextFieldModal,
      child: Container(
        constraints: dimens.richTextFieldConstraints,
        decoration: BoxDecoration(
          borderRadius: dimens.genericRoundedElementBorderRadius,
          color: inputDecorationTheme.fillColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasContent) ...[
              Text(placeholder, style: textTheme.caption?.copyWith(color: theme.neutralSwatch.shade400)),
              context.verticalBox(Spacing.small),
              Flexible(
                child: AbsorbPointer(
                  child: _ThemedEditor(
                    controller: richFieldController.value,
                    placeholder: placeholder,
                    backgroundColor: theme.neutralSwatch.shade700,
                    showCursor: false,
                    readonly: true,
                  ),
                ),
              ),
            ] else
              Text(placeholder, style: textTheme.subtitle1)
          ],
        ).withSymmetricalPadding(context, vertical: Spacing.small, horizontal: Spacing.medium),
      ),
    );
  }
}

/// A controller for [RichTextField].
///
/// It works in the same way as [TextEditingController], but with support to rich text content.
class RichTextEditingController extends ChangeNotifier {
  RichTextEditingController({String? initialText}) : _richTextContent = initialText ?? '';

  String _richTextContent;
  String get richTextContent => _richTextContent;

  void update(String content) {
    _richTextContent = content;
    notifyListeners();
  }
}

/// Rich text editor modal.
///
/// Holds the rich text editor using [quill] library.
/// Places [_RichTextFieldToolbar] - a toolbar of actions to customize the text content - above the keyboard when it's
/// visible.
@visibleForTesting
class RichTextFieldModal extends HookWidget {
  const RichTextFieldModal({required this.title, required this.controller, required this.placeholder});

  final Widget title;
  final quill.QuillController controller;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final editor = _ThemedEditor(
      controller: controller,
      placeholder: placeholder,
      backgroundColor: theme.neutralSwatch.shade800,
    );

    final okButton = CustomTextButton(
      text: strings.ok.toUpperCase(),
      onPressed: Navigator.of(context).pop,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerRight, child: okButton),
              context.verticalBox(Spacing.xxxSmall),
              title,
              context.verticalBox(Spacing.xxSmall),
              Expanded(child: editor),
              context.verticalBox(Spacing.xxSmall),
            ],
          ).withSymmetricalPadding(context, horizontal: Spacing.medium),
        ),
        // Only show toolbar action items when the keyboard is visible
        if (keyboardHeight > 0) ...[
          _RichTextFieldToolbar(controller),
          SizedBox(height: keyboardHeight),
        ]
      ],
    );
  }
}

/// Provides a custom styled and reusable [quill.QuillEditor].
///
/// Ideally this wrapper would not be necessary but `quill` forces us to provide a set of attributes when building a
/// [quill.QuillEditor] that are shared between this file editor instances.
///
/// It basically reduces boilerplate.
class _ThemedEditor extends HookWidget {
  const _ThemedEditor({
    required this.controller,
    required this.backgroundColor,
    required this.placeholder,
    this.showCursor = true,
    this.readonly = false,
  });

  final quill.QuillController controller;
  final Color backgroundColor;
  final String placeholder;
  final bool showCursor;
  final bool readonly;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final textTheme = Theme.of(context).textTheme;
    const zeroTuple = Tuple2<double, double>(0, 0);

    return quill.QuillEditor(
      controller: controller,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: FocusNode(),
      autoFocus: true,
      readOnly: readonly,
      expands: false,
      padding: EdgeInsets.zero,
      showCursor: showCursor,
      // TODO(ggirotto): Placeholder is crashing. This is a problem related to `FlutterQuill`.
      // TODO(ggirotto): https://github.com/singerdmx/flutter-quill/issues/348
      // placeholder: placeholder,
      customStyles: quill.DefaultStyles(
        paragraph: quill.DefaultTextBlockStyle(textTheme.bodyText2!, zeroTuple, zeroTuple, null),
        placeHolder: quill.DefaultTextBlockStyle(
          textTheme.bodyText1!.copyWith(color: theme.neutralSwatch.shade400),
          zeroTuple,
          zeroTuple,
          null,
        ),
        code: quill.DefaultTextBlockStyle(
          textTheme.bodyText1!,
          zeroTuple,
          zeroTuple,
          BoxDecoration(color: backgroundColor),
        ),
      ),
    );
  }
}

enum _ToolbarAttribute { bold, italic, underline, code }

/// A toolbar of actions to customize the editor content.
class _RichTextFieldToolbar extends HookWidget {
  _RichTextFieldToolbar(this.controller);

  final quill.QuillController controller;

  /// Maps [_ToolbarAttribute] to `quill`s native [quill.Attribute] class.
  final Map<_ToolbarAttribute, quill.Attribute<dynamic>> _toolBarAttributes = {
    _ToolbarAttribute.bold: quill.Attribute.bold,
    _ToolbarAttribute.italic: quill.Attribute.italic,
    _ToolbarAttribute.underline: quill.Attribute.underline,
    _ToolbarAttribute.code: quill.Attribute.codeBlock,
  };

  /// Maps [_ToolbarAttribute] to its respective asset.
  final Map<_ToolbarAttribute, String> _toolBarAsset = {
    _ToolbarAttribute.bold: images.bold,
    _ToolbarAttribute.italic: images.italic,
    _ToolbarAttribute.underline: images.underline,
    _ToolbarAttribute.code: images.code,
  };

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();

    final selectedAttributes = useState<List<_ToolbarAttribute>>([]);

    void onToggle(_ToolbarAttribute attribute) {
      final hasAttribute = selectedAttributes.value.any((currentAttribute) => currentAttribute == attribute);

      if (hasAttribute) {
        selectedAttributes.value = [...selectedAttributes.value..remove(attribute)];
        controller.formatSelection(quill.Attribute.clone(_toolBarAttributes[attribute]!, null));
      } else {
        selectedAttributes.value = [...selectedAttributes.value..add(attribute)];
        controller.formatSelection(_toolBarAttributes[attribute]);
      }
    }

    bool isSelected(_ToolbarAttribute attribute) => selectedAttributes.value.contains(attribute);

    final attributesIcons = _ToolbarAttribute.values
        .map((attribute) => AssetIconButton(
              _toolBarAsset[attribute]!,
              iconColor: isSelected(attribute) ? theme.neutralSwatch.shade800 : null,
              iconBackgroundColor: isSelected(attribute) ? theme.neutralSwatch.shade500 : null,
              isSplashEffectEnabled: false,
              onPressed: () => onToggle(attribute),
            ))
        .toList();

    return ThemedBottomContainer(
      child: Container(
        color: theme.neutralSwatch.shade800,
        child: SafeArea(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: attributesIcons),
        ),
      ),
    );
  }
}
