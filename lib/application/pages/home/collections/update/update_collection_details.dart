import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/exception_strings.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/hooks/rich_text_field_controller_hook.dart';
import 'package:memo/application/hooks/tags_controller_hook.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_metadata.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/update_collection_details_vm.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';
import 'package:memo/application/widgets/theme/custom_text_field.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';
import 'package:memo/application/widgets/theme/tags_field.dart';
import 'package:memo/application/widgets/unfocus_pointer.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';
import 'package:memo/domain/validators/collection_validators.dart' as validators;

class UpdateCollectionDetails extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentVM = ref.watch(updateCollectionVM.notifier);

    ref.listen<UpdatedDetailsState>(
      updateCollectionDetailsVM,
      (_, state) => parentVM.updateMetadata(metadata: state.metadata),
    );

    return UnfocusPointer(
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
    final vm = ref.watch(updateCollectionDetailsVM.notifier);
    final state = ref.watch(updateCollectionDetailsVM);
    final hasInitialData = useState(false);

    final controller = useTextEditingController(text: state.metadata.name);
    final nameLength = state.metadata.name.length;

    return StreamBuilder(
      stream: vm.name,
      builder: (context, snapshot) {
        return CustomTextField(
          controller: controller,
          onChanged: (updatedName) {
            vm.updateName(updatedName ?? '');
            hasInitialData.value = true;
          },
          labelText: strings.collectionName,
          inputFormatters: [
            LengthLimitingTextInputFormatter(validators.collectionNameMaxLength),
          ],
          helperText: strings.fieldCharactersAmount(nameLength, validators.collectionNameMaxLength),
          errorText: snapshot.hasError && hasInitialData.value
              ? descriptionForException(snapshot.error! as BaseException)
              : null,
        );
      },
    );
  }
}

class _TagsField extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(updateCollectionDetailsVM.notifier);
    final state = ref.watch(updateCollectionDetailsVM);

    final hasInitialData = useState(false);
    final controller = useTagsController(tags: state.metadata.tags);

    useEffect(
      () {
        void onTagsUpdate() {
          vm.updateTags(controller.tags);
          hasInitialData.value = true;
        }

        controller.addListener(onTagsUpdate);
        return () => controller.removeListener(onTagsUpdate);
      },
      [],
    );

    return StreamBuilder(
      stream: vm.tags,
      builder: (context, snapshot) {
        return TagsField(
          controller: controller,
          errorText: snapshot.hasError && hasInitialData.value
              ? descriptionForException(snapshot.error! as BaseException)
              : null,
        );
      },
    );
  }
}

class _DescriptionField extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;
    final vm = ref.watch(updateCollectionDetailsVM.notifier);
    final state = ref.watch(updateCollectionDetailsVM);

    final hasInitialData = useState(false);
    final controller = useRichTextEditingController(richText: state.metadata.description.richContent);

    useEffect(
      () {
        void onDescriptionUpdate() {
          final content = mapRichTextValueToMemoUpdateContent(controller.value);
          vm.updateDescription(content);
          hasInitialData.value = true;
        }

        controller.addListener(onDescriptionUpdate);

        return () => controller.removeListener(onDescriptionUpdate);
      },
      [],
    );

    final descriptionLength = state.metadata.description.plainContent.length;

    return StreamBuilder(
      stream: vm.description,
      builder: (context, snapshot) {
        return RichTextField(
          controller: controller,
          modalTitle: Text(
            strings.detailsDescription,
            style: textTheme.bodyText1?.copyWith(color: theme.primarySwatch.shade400),
          ),
          placeholder: strings.collectionDescription,
          helperText: strings.fieldCharactersAmount(descriptionLength, validators.collectionDescriptionMaxLength),
          errorText: snapshot.hasError && hasInitialData.value
              ? descriptionForException(snapshot.error! as BaseException)
              : null,
        );
      },
    );
  }
}
