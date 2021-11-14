import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/bottom_sheet.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/highlightable_text.dart';

/// Controls and supports tags suggestions lifecycle of [TagsField].
class SuggestionsController extends StateNotifier<SuggestionsState> {
  SuggestionsController() : super(const SuggestionsState(suggestions: [], isLoading: false));

  /// The maximum amount of suggestions loaded when calling [loadSuggestions].
  static const _maxSuggestionsAmount = 5;

  Future<void> loadSuggestions(String search) async {
    state = SuggestionsState(suggestions: state.suggestions, isLoading: true, searchTerm: search);

    /// TODO(ggirotto): Use services to fetch suggestions
    await Future<void>.delayed(const Duration(seconds: 3));
    state = SuggestionsState(suggestions: const ['A', 'B', 'C'], isLoading: false, searchTerm: search);
  }

  void clearSuggestions() {
    state = const SuggestionsState(suggestions: [], isLoading: false);
  }
}

@immutable
class SuggestionsState extends Equatable {
  const SuggestionsState({required this.suggestions, required this.isLoading, this.searchTerm});

  /// List of tags suggestions when searching by [searchTerm].
  ///
  /// Will be empty if [searchTerm] is `null`.
  final List<String> suggestions;

  /// Returns `true` if the suggestions list request is ongoing.
  final bool isLoading;

  /// Sentence being searched.
  ///
  /// All [suggestions] must have this term as prefix.
  final String? searchTerm;

  @override
  List<Object?> get props => [suggestions, isLoading, searchTerm];
}

/// Provides the list of tags of the collection being updated.
///
/// These tags may be mutated by [TagsField], which the user may use to update the tags list.
final tagsController = StateProvider<List<String>>((_) => []);

/// Provides internal control of tags suggestions.
final suggestionsController =
    StateNotifierProvider<SuggestionsController, SuggestionsState>((_) => SuggestionsController());

/// A custom [TextField] that groups a collection of tags.
///
/// Different from usual TextFields, when the field is tapped it opens a modal page where the user may input the tags,
/// which will be later reflected in the collapsed interface. The maximum amount of tags allowed is defined by
/// [maxTags].
///
/// The presented modal also loads a list of suggestions while the user types, similar as how search webpages. The delay
/// between the user typing and the suggestions requests is defined by [suggestionsThrottleInSeconds].
class TagsField extends ConsumerWidget {
  const TagsField({this.maxTags = 5, this.suggestionsThrottleInSeconds = 1});

  /// {@template TagsDropdownField.maxTags}
  /// Maximum number of tags allowed to be chosen.
  ///
  /// Inputs that would increase this amount will be ignored, i.e, not transformed in tags.
  /// {@endtemplate}
  final int maxTags;

  /// {@template TagsDropdownField.suggestionsThrottleInSeconds}
  /// The duration - in seconds - that the component waits before loading the suggestions.
  /// {@endtemplate}
  final int suggestionsThrottleInSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme(ref);
    final textTheme = Theme.of(context).textTheme;

    final _tagsController = ref.watch(tagsController);
    final _suggestionsController = ref.watch(suggestionsController.notifier);

    Future<void> showTagsModal() async {
      final modal = _TagsModal(maxTags: maxTags, suggestionsThrottleInSeconds: suggestionsThrottleInSeconds);
      await showSnappableDraggableModalBottomSheet<void>(context, ref, child: modal);
      _suggestionsController.clearSuggestions();
    }

    return GestureDetector(
      onTap: showTagsModal,
      child: Container(
        constraints: dimens.richTextFieldConstraints,
        decoration: BoxDecoration(
          borderRadius: dimens.genericRoundedElementBorderRadius,
          color: theme.neutralSwatch.shade700,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_tagsController.isNotEmpty) ...[
              Text(strings.addTags(maxTags), style: textTheme.caption?.copyWith(color: theme.neutralSwatch.shade300)),
              context.verticalBox(Spacing.small),
              const _TagsTextField(readonly: true),
            ] else
              Text(strings.addTags(maxTags), style: textTheme.subtitle1)
          ],
        ).withSymmetricalPadding(context, vertical: Spacing.small, horizontal: Spacing.medium),
      ),
    );
  }
}

/// The modal that is presented when tapping [TagsField].
///
/// Allows the user to update the collection tags by adding new or removing the existing ones.
///
/// Loads a list of suggestions while the user types, similar as how search webpages do. The delay between the user
/// typing and the suggestions requests is defined by [suggestionsThrottleInSeconds].
class _TagsModal extends HookConsumerWidget {
  const _TagsModal({required this.maxTags, required this.suggestionsThrottleInSeconds});

  /// {@macro TagsDropdownField.maxTags}
  final int maxTags;

  /// {@macro TagsDropdownField.suggestionsThrottleInSeconds}
  final int suggestionsThrottleInSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme(ref);
    final textTheme = Theme.of(context).textTheme;

    final _tagsController = ref.watch(tagsController.notifier);
    final selectedTags = ref.watch(tagsController);
    final _suggestionsController = ref.watch(suggestionsController.notifier);
    final suggestionsState = ref.watch(suggestionsController);

    final fieldFocus = useFocusNode();
    final fieldController = useTextEditingController();
    final isFieldFocused = useState(false);

    void onTagSelected(String tag) {
      _suggestionsController.clearSuggestions();
      fieldController.clear();
      fieldFocus.requestFocus();
      if (selectedTags.length < maxTags && tag.isNotEmpty && !selectedTags.contains(tag)) {
        _tagsController.state = [...selectedTags, tag];
      }
    }

    useEffect(() {
      Timer? throttleTimer;
      void onFocusUpdate() => isFieldFocused.value = fieldFocus.hasFocus;
      void onSearchUpdated() {
        throttleTimer?.cancel();
        final term = fieldController.text;
        if (term.isEmpty) {
          _suggestionsController.clearSuggestions();
          return;
        }

        final lastChar = fieldController.text.characters.last;
        if (lastChar == ' ' || lastChar == ',') {
          onTagSelected(fieldController.text.substring(0, fieldController.text.length - 1));
          return;
        }

        throttleTimer = Timer(Duration(seconds: suggestionsThrottleInSeconds), () {
          _suggestionsController.loadSuggestions(term);
        });
      }

      fieldFocus.addListener(onFocusUpdate);
      fieldController.addListener(onSearchUpdated);

      return () {
        fieldFocus.removeListener(onFocusUpdate);
        fieldController.removeListener(onSearchUpdated);
        throttleTimer?.cancel();
      };
    });

    final dismissButton = Align(
      alignment: Alignment.centerRight,
      child: CustomTextButton(text: strings.ok.toUpperCase(), onPressed: Navigator.of(context).pop),
    );

    final title = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(strings.tags, style: textTheme.caption?.copyWith(color: theme.neutralSwatch.shade300)),
        context.horizontalBox(Spacing.medium),
        Text(
          '${selectedTags.length}/$maxTags',
          style: textTheme.caption?.copyWith(color: theme.neutralSwatch.shade300),
        )
      ],
    );

    final tagsField = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: fieldFocus.requestFocus,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _TagsTextField(
              fieldController: fieldController,
              focus: fieldFocus,
              onSubmitted: onTagSelected,
            ),
          ),
          if (suggestionsState.isLoading)
            const SizedBox(
              height: dimens.tagsSuggestionLoadingSize,
              width: dimens.tagsSuggestionLoadingSize,
              child: CircularProgressIndicator(strokeWidth: dimens.tagsSuggestionLoadingStrokeWidth),
            ).withOnlyPadding(context, top: Spacing.xxSmall),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        dismissButton,
        context.verticalBox(Spacing.small),
        title,
        context.verticalBox(Spacing.xxxSmall),
        tagsField,
        if (suggestionsState.suggestions.isNotEmpty) ...[
          context.verticalBox(Spacing.large),
          Expanded(child: _TagsSuggestions(onTap: onTagSelected)),
        ]
      ],
    ).withSymmetricalPadding(context, horizontal: Spacing.medium);
  }
}

/// A list of tags suggestions.
///
/// Triggers [onTap] with the chosen suggestion when tapped.
class _TagsSuggestions extends ConsumerWidget {
  const _TagsSuggestions({required this.onTap});

  final void Function(String suggestion) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme(ref);
    final textTheme = Theme.of(context).textTheme;
    final suggestionsState = ref.watch(suggestionsController);

    final title = Text(strings.suggestions, style: textTheme.subtitle1?.copyWith(color: theme.neutralSwatch.shade300));

    Widget buildRow(String suggestion) {
      return Material(
        child: InkWell(
          onTap: () => onTap(suggestion),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: dimens.genericRoundedElementBorderRadius,
              color: theme.neutralSwatch.shade800,
            ),
            child: HighlightableText(
              text: suggestion,
              textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: theme.neutralSwatch.shade300),
              highlighted: suggestionsState.searchTerm,
              highlightedStyle: Theme.of(context).textTheme.subtitle2,
            ).withAllPadding(context, Spacing.medium),
          ),
        ),
      );
    }

    final suggestionsRows = suggestionsState.suggestions.mapIndexed((index, suggestion) {
      return buildRow(suggestion).withOnlyPadding(context, top: index > 0 ? Spacing.small : null);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        context.verticalBox(Spacing.small),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: suggestionsRows.toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// The custom tagged TextField.
///
/// Wraps the already chosen tags with an input [TextField] used to add new tags.
class _TagsTextField extends ConsumerWidget {
  const _TagsTextField({this.fieldController, this.focus, this.onSubmitted, this.readonly = false});

  final TextEditingController? fieldController;

  /// Controls the current field focus.
  final FocusNode? focus;

  /// Called when the user indicates they are done inputting `tag`.
  ///
  /// Usually fired when the user press the "done" keyboard button.
  final Function(String tag)? onSubmitted;

  /// Wether the tag `TextField` can be changed.
  ///
  /// If `true` all modifiable interactions are ignored. The text is still selectable though.
  final bool readonly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme(ref);
    final textTheme = Theme.of(context).textTheme;
    final _tagsController = ref.watch(tagsController.notifier);

    void onTagTap(String tag) => _tagsController.state = _tagsController.state..remove(tag);
    final tags = _tagsController.state.map((tag) => _SelectedTag(tag: tag, readonly: readonly, onTap: onTagTap));

    final textField = TextField(
      focusNode: focus,
      controller: fieldController,
      cursorColor: theme.secondarySwatch,
      autocorrect: false,
      readOnly: readonly,
      enableSuggestions: false,
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        fillColor: Colors.transparent,
        hintText: readonly ? null : strings.tagsHint,
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
        ...tags,
        IntrinsicWidth(child: textField),
      ],
    );
  }
}

class _SelectedTag extends ConsumerWidget {
  const _SelectedTag({required this.tag, this.readonly = false, this.onTap});

  final String tag;

  /// If `true` all interactions with the tag are ignored - meaning [onTap] will be never fired.
  ///
  /// It also removes the close asset, which indicates that the tag is interactable.
  final bool readonly;

  /// Called when the user taps in the respective tag.
  final void Function(String tag)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme(ref);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: InkWell(
        onTap: readonly ? null : () => onTap?.call(tag),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: dimens.textTagBorderRadius,
            color: theme.secondarySwatch.shade600,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tag, style: textTheme.caption),
              if (!readonly) ...[
                context.horizontalBox(Spacing.xxxSmall),
                Image.asset(images.closeAsset, height: dimens.tagsCloseButtonSize, width: dimens.tagsCloseButtonSize),
              ]
            ],
          ).withAllPadding(context, Spacing.xxSmall),
        ),
      ),
    );
  }
}

/// Formats the text from [_TagsTextField] `TextField`.
class _TagFieldFormatter extends TextInputFormatter {
  static const _maxTagLength = 15;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > _maxTagLength) {
      return TextEditingValue(text: oldValue.text, selection: oldValue.selection);
    }

    // Restrict the content to only accept alphanumeric space, underscore and comma characters.
    final alphanumRegex = RegExp(r'^[a-zA-Z0-9_ ,]*$');
    if (!alphanumRegex.hasMatch(newValue.text)) {
      return TextEditingValue(text: oldValue.text, selection: oldValue.selection);
    }

    // Forces uppercase capitalization.
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
