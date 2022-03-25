import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/hooks/tags_controller_hook.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/domain/validators/collection_validators.dart';

/// A controller for [TagsField].
///
/// It shares the same behavior and characteristics as [TextEditingController] but in the context of [TagsField] instead
/// [TextField]. It means that this controller may be initialized with an initial list of [tags] and that it notify its
/// listeners once these tags are updated. To listen to such updates, attach a listener to the current controller by
/// using [addListener] function.
///
/// See also:
/// * [TextEditingController], which shares the same behavior as this controller.
/// * [TagsField], the Widget controlled by this controller.
class TagsEditingController extends ValueNotifier<List<String>> {
  TagsEditingController({List<String>? tags}) : super(tags ?? []);

  List<String> get tags => value;

  set tags(List<String> tags) => value = List.from(tags);
}

/// A custom [TextField] that groups a collection of tags.
class TagsField extends HookConsumerWidget {
  const TagsField({this.controller, this.maxTags = 5, this.errorText});

  /// Controls the tags being edited.
  ///
  /// If null, this widget will create its own [TagsEditingController].
  final TagsEditingController? controller;

  /// {@template TagsField.maxTags}
  /// Maximum allowed tags to be selected simultaneously.
  /// {@endtemplate}
  final int maxTags;

  /// {@macro CustomTextField.errorText}
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = this.controller ?? useTagsController();
    final tags = useState(controller.tags);

    final fieldFocus = useFocusNode();
    final fieldController = useTextEditingController();
    final isFocused = useState(fieldFocus.hasFocus || controller.tags.isNotEmpty);

    void onTagSelected(String tag) {
      fieldController.clear();
      fieldFocus.requestFocus();
      if (controller.tags.length < maxTags && tag.isNotEmpty && !controller.tags.contains(tag)) {
        controller.tags = [...controller.tags, tag];
      }
    }

    useEffect(() {
      void onFieldChanged() {
        final characters = fieldController.text.characters;
        final lastChar = characters.isNotEmpty ? characters.last : null;
        if (lastChar == ' ' || lastChar == ',') {
          onTagSelected(fieldController.text.substring(0, fieldController.text.length - 1));
        }
      }

      void onTagsUpdate() {
        isFocused.value = fieldFocus.hasFocus || controller.tags.isNotEmpty;
        tags.value = controller.tags;
      }

      void onFocusUpdate() => isFocused.value = fieldFocus.hasFocus || tags.value.isNotEmpty;

      fieldController.addListener(onFieldChanged);
      fieldFocus.addListener(onFocusUpdate);
      controller.addListener(onTagsUpdate);

      return () {
        fieldController.removeListener(onFieldChanged);
        fieldFocus.removeListener(onFocusUpdate);
        controller.removeListener(onTagsUpdate);
      };
    });

    return GestureDetector(
      onTap: () {
        fieldFocus.requestFocus();
        isFocused.value = true;
      },
      child: _TagsFieldContainer(
        tagsField: _TagsTextField(
          controller: controller,
          fieldController: fieldController,
          focus: fieldFocus,
          onSubmitted: onTagSelected,
        ),
        tagsAmount: tags.value.length,
        maxTags: maxTags,
        hasFocus: isFocused.value,
        errorText: errorText,
      ),
    );
  }
}

/// Wraps [tagsField] in a container that provides the same visual layout as the application [TextField]s.
class _TagsFieldContainer extends ConsumerWidget {
  const _TagsFieldContainer({
    required this.tagsField,
    required this.tagsAmount,
    required this.maxTags,
    required this.hasFocus,
    required this.errorText,
  });

  /// The tags [TextField] that has the selected tags as a prefix of the input field.
  final Widget tagsField;

  /// The amount of tags that the user already selected.
  final int tagsAmount;

  /// {@macro TagsField.maxTags}
  final int maxTags;

  /// `true` if the tags field has focus.
  final bool hasFocus;

  /// {@macro CustomTextField.errorText}
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;
    final textInputDecoration = Theme.of(context).inputDecorationTheme;

    // Simulates `TextField.helperText` animating the label when the field is focused or not.
    final helperTitle = AnimatedDefaultTextStyle(
      style: hasFocus ? textTheme.caption!.copyWith(color: theme.neutralSwatch.shade300) : textTheme.subtitle1!,
      duration: anims.textFieldHelperTextDuration,
      child: const Text(strings.addTags),
    );

    final helperText = Text(
      errorText != null ? errorText! : strings.tagsAmount(tagsAmount, maxTags),
      style: textTheme.caption?.copyWith(
        color: errorText != null ? theme.destructiveSwatch : theme.neutralSwatch.shade400,
      ),
    );

    final tagsFieldContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        helperTitle,
        if (hasFocus) ...[
          context.verticalBox(Spacing.small),
          tagsField,
        ]
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: dimens.richTextFieldConstraints,
          decoration: BoxDecoration(
            borderRadius: dimens.genericRoundedElementBorderRadius,
            color: textInputDecoration.fillColor,
            border: Border.all(
              color: errorText != null ? theme.destructiveSwatch : textInputDecoration.fillColor!,
              width: dimens.genericBorderHeight,
            ),
          ),
          child: tagsFieldContent.withSymmetricalPadding(context, vertical: Spacing.small, horizontal: Spacing.medium),
        ),
        context.verticalBox(Spacing.xxxSmall),
        helperText.withOnlyPadding(context, left: Spacing.small)
      ],
    );
  }
}

/// The custom tagged TextField.
///
/// Wraps the already chosen tags with an input [TextField] used to add new tags.
class _TagsTextField extends HookConsumerWidget {
  const _TagsTextField({required this.controller, this.fieldController, this.focus, this.onSubmitted});

  final TagsEditingController controller;
  final TextEditingController? fieldController;

  /// Controls the current field focus.
  final FocusNode? focus;

  /// Called when the user submits a `tag` input by pressing "done" in the keyboard.
  final void Function(String tag)? onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;

    final tags = useState(controller.tags);
    void onTagTap(String tag) {
      controller.tags = controller.tags..remove(tag);
      tags.value = controller.tags;
    }

    final tagsWidgets = controller.tags.map((tag) => _SelectedTag(tag: tag, onTap: onTagTap));

    final textField = TextField(
      focusNode: focus,
      controller: fieldController,
      cursorColor: theme.secondarySwatch,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        fillColor: Colors.transparent,
        hintText: strings.tagsHint,
        hintStyle: textTheme.bodyText2?.copyWith(color: theme.neutralSwatch.shade600),
      ),
      textAlignVertical: TextAlignVertical.center,
      style: textTheme.bodyText2,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      inputFormatters: [_TagFieldFormatter()],
      onSubmitted: (term) {
        fieldController?.clear();
        onSubmitted?.call(term);
        focus?.requestFocus();
      },
    );

    return Wrap(
      spacing: context.rawSpacing(Spacing.small),
      runSpacing: context.rawSpacing(Spacing.small),
      children: [
        ...tagsWidgets,
        IntrinsicWidth(child: textField),
      ],
    );
  }
}

class _SelectedTag extends ConsumerWidget {
  const _SelectedTag({required this.tag, this.onTap});

  final String tag;

  /// Called when the user taps in the respective tag.
  final void Function(String tag)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: InkWell(
        onTap: onTap != null ? () => onTap!(tag) : null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: dimens.textTagBorderRadius,
            color: theme.secondarySwatch.shade600,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tag, style: textTheme.caption),
              context.horizontalBox(Spacing.xxxSmall),
              Image.asset(images.closeAsset, height: dimens.tagsRemoveIconSize, width: dimens.tagsRemoveIconSize),
            ],
          ).withAllPadding(context, Spacing.xxSmall),
        ),
      ),
    );
  }
}

/// Formats the text from [_TagsTextField] `TextField`.
class _TagFieldFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > collectionTagMaxLength) {
      return TextEditingValue(text: oldValue.text, selection: oldValue.selection);
    }

    // Restrict the content to only accept alphanumeric space, underscore and comma characters.
    if (!collectionTagRegex.hasMatch(newValue.text)) {
      return TextEditingValue(text: oldValue.text, selection: oldValue.selection);
    }

    // Forces uppercase capitalization.
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
