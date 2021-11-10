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
  const RichTextField({required this.modalTitle, required this.placeholder, this.controller, this.focus});

  /// The modal title positioned in the top-left corner of the modal editor.
  final Widget modalTitle;

  /// The placeholder used in the rich text editor when it has no content.
  final String placeholder;

  /// Controls the text content being edited.
  final TextEditingController? controller;

  final FocusNode? focus;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final textTheme = Theme.of(context).textTheme;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    final quillController = _useQuillController(textController: controller);

    useEffect(() {
      void editorChanged() => controller?.text = jsonEncode(quillController.document.toDelta().toJson());

      quillController.addListener(editorChanged);
      return () => quillController.removeListener(editorChanged);
    });

    Future<void> showRichTextFieldModal() async {
      await showSnappableDraggableModalBottomSheet<void>(
        context,
        child: _RichTextFieldModal(
          title: modalTitle,
          controller: quillController,
          placeholder: placeholder,
          focus: focus,
        ),
      );
    }

    final content = quillController.plainTextEditingValue.text;
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
                    controller: quillController,
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

/// Rich text editor modal.
///
/// Holds the rich text editor using `flutter_quill` library.
/// Places [_RichTextFieldToolbar] - a toolbar of actions to customize the text content - above the keyboard when it's
/// visible.
class _RichTextFieldModal extends HookWidget {
  const _RichTextFieldModal({required this.title, required this.controller, required this.placeholder, this.focus});

  final Widget title;
  final quill.QuillController controller;
  final String placeholder;
  final FocusNode? focus;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();

    final focusNode = focus ?? useFocusNode();
    final isFocused = useState(focusNode.hasFocus);

    useEffect(() {
      void focusUpdate() => isFocused.value = focusNode.hasFocus;

      focusNode.addListener(focusUpdate);
      return () => focusNode.removeListener(focusUpdate);
    });

    final editor = _ThemedEditor(
      controller: controller,
      placeholder: placeholder,
      backgroundColor: theme.neutralSwatch.shade800,
      focus: focusNode,
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
        if (isFocused.value) ...[
          _RichTextFieldToolbar(controller),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
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
    this.focus,
    this.showCursor = true,
    this.readonly = false,
  });

  final quill.QuillController controller;
  final Color backgroundColor;
  final String placeholder;
  final FocusNode? focus;
  final bool showCursor;
  final bool readonly;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final textTheme = Theme.of(context).textTheme;

    // Default [quill.DefaultTextBlockStyle] vertical and line spacings.
    const zeroTuple = Tuple2<double, double>(0, 0);

    return quill.QuillEditor(
      controller: controller,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: focus ?? FocusNode(),
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

/// A toolbar of actions to customize the editor content.
class _RichTextFieldToolbar extends HookWidget {
  _RichTextFieldToolbar(this.controller);

  final quill.QuillController controller;

  /// Maps [quill.Attribute] to its respective asset.
  final Map<quill.Attribute<dynamic>, String> _toolBarAsset = {
    quill.Attribute.bold: images.boldAsset,
    quill.Attribute.italic: images.italicAsset,
    quill.Attribute.underline: images.underlineAsset,
    quill.Attribute.codeBlock: images.codeAsset,
  };

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();

    final selectedAttributes = useState<Set<quill.Attribute>>(controller.getSelectionStyle().attributes.values.toSet());

    useEffect(() {
      void updateAttributes() {
        selectedAttributes.value = Set.from(controller.getSelectionStyle().attributes.values.toSet());
      }

      controller.addListener(updateAttributes);
      return () => controller.removeListener(updateAttributes);
    });

    void onToggle(quill.Attribute attribute) {
      final hasAttribute = selectedAttributes.value.any((currentAttribute) => currentAttribute == attribute);

      if (hasAttribute) {
        controller.formatSelection(quill.Attribute.clone(attribute, null));
      } else {
        controller.formatSelection(attribute);
      }
    }

    bool isSelected(quill.Attribute attribute) => selectedAttributes.value.contains(attribute);

    final attributesIcons = _toolBarAsset.keys
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

const _useQuillController = _QuillControllerHookCreator();

class _QuillControllerHookCreator {
  const _QuillControllerHookCreator();

  /// Creates a [quill.QuillController] that will be disposed automatically.
  ///
  /// The [textController] parameter can be used to set the initial value of the controller text ands its selection.
  quill.QuillController call({TextEditingController? textController, List<Object?>? keys}) =>
      use(_QuillControllerHook(textController: textController, keys: keys));
}

class _QuillControllerHook extends Hook<quill.QuillController> {
  const _QuillControllerHook({this.textController, List<Object?>? keys = const []}) : super(keys: keys);

  final TextEditingController? textController;

  @override
  _QuillControllerHookState createState() => _QuillControllerHookState();
}

class _QuillControllerHookState extends HookState<quill.QuillController, _QuillControllerHook> {
  late final quill.QuillController _controller;

  @override
  void initHook() {
    final text = hook.textController?.text;
    final hasText = text != null && text.isNotEmpty;

    final selection = hook.textController?.selection;
    final hasSelection = selection != null && selection.isValid;

    final document = hasText ? quill.Document.fromJson(json.decode(text!) as List<dynamic>) : quill.Document();
    final selectionOffset = document.toPlainText().isNotEmpty ? document.toPlainText().length - 1 : 0;

    _controller = quill.QuillController(
      document: document,
      selection: hasSelection ? selection! : TextSelection.collapsed(offset: selectionOffset),
    );
  }

  @override
  quill.QuillController build(BuildContext context) => _controller;

  @override
  void dispose() => _controller.dispose();

  @override
  String get debugLabel => 'useQuillController';
}
