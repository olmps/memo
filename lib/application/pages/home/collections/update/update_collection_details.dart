import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/exception_strings.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/hooks/rich_text_field_controller_hook.dart';
import 'package:memo/application/hooks/tags_controller_hook.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/update_collection_details_vm.dart';
import 'package:memo/application/widgets/theme/custom_text_field.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';
import 'package:memo/application/widgets/theme/tags_field.dart';
import 'package:memo/application/widgets/unfocus_detector.dart';
import 'package:memo/domain/validators/collection_validators.dart' as validators;

class UpdateCollectionDetails extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return UnfocusDetector(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _NameField(),
            context.verticalBox(Spacing.large),
            _TagsField(),
            context.verticalBox(Spacing.large),
            _DescriptionField(),
          ],
        ).withSymmetricalPadding(context, vertical: Spacing.large, horizontal: Spacing.small),
      ),
    );
  }
}

class _NameField extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(updateCollectionDetailsVM.notifier);
    final state = ref.watch(updateCollectionDetailsVM);

    final controller = useTextEditingController(text: state.metadata.name);
    final focus = useFocusNode();

    useEffect(() {
      void onNameUpdate() => vm.updateName(controller.text);

      controller.addListener(onNameUpdate);
      return () => controller.removeListener(onNameUpdate);
    });

    final nameLength = state.metadata.name.length;
    return CustomTextField(
      controller: controller,
      focusNode: focus,
      labelText: strings.collectionName,
      inputFormatters: [
        LengthLimitingTextInputFormatter(validators.collectionNameMaxLength),
      ],
      helperText: '$nameLength/${validators.collectionNameMaxLength} caracteres',
      errorText: state is UpdateDetailsInvalid && state.nameException != null && !focus.hasFocus
          ? descriptionForException(state.nameException!)
          : null,
    );
  }
}

class _TagsField extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(updateCollectionDetailsVM.notifier);

    final controller = useTagsController();

    useEffect(() {
      void onTagsUpdate() => vm.updateTags(controller.tags);

      controller.addListener(onTagsUpdate);
      return () => controller.removeListener(onTagsUpdate);
    });

    return const TagsField();
  }
}

class _DescriptionField extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;
    final vm = ref.read(updateCollectionDetailsVM.notifier);
    final state = ref.watch(updateCollectionDetailsVM);

    final controller = useRichTextEditingController(richText: state.metadata.description.richText);
    final focus = useFocusNode();
    final hasFocus = useState(focus.hasFocus);

    useEffect(() {
      void onDescriptionUpdate() => vm.updateDescription(controller.value);
      void onFocusUpdate() => hasFocus.value = focus.hasFocus;

      controller.addListener(onDescriptionUpdate);
      focus.addListener(onFocusUpdate);

      return () {
        controller.removeListener(onDescriptionUpdate);
        focus.removeListener(onFocusUpdate);
      };
    });

    final descriptionLength = state.metadata.description.plainText.length;
    return RichTextField(
      controller: controller,
      focus: focus,
      modalTitle: Text(
        strings.detailsDescription,
        style: textTheme.bodyText1?.copyWith(color: theme.primarySwatch.shade400),
      ),
      placeholder: strings.collectionDescription,
      helperText: '$descriptionLength/${validators.collectionDescriptionMaxLength} caracteres',
      errorText: state is UpdateDetailsInvalid && state.descriptionException != null && !focus.hasFocus
          ? descriptionForException(state.descriptionException!)
          : null,
    );
  }
}
