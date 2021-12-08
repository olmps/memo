import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/strings.dart' as string;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/theme/tags_field.dart';

import '../../../utils/widget_pump.dart';

void main() {
  group('Field Formatter - ', () {
    testWidgets('should respect max tags length', (tester) async {
      const tagsField = TagsField();
      final invalidLengthTag = 'a' * 20;

      await _pumpWithTag(field: tagsField, tester: tester, tag: invalidLengthTag);

      expect(find.text(invalidLengthTag.toUpperCase()), findsNothing);
    });

    testWidgets('should uppercase input text', (tester) async {
      const tagsField = TagsField();
      const lowerCaseText = 'text';
      final expectedTag = lowerCaseText.toUpperCase();

      await _pumpWithTag(field: tagsField, tester: tester, tag: lowerCaseText);

      expect(find.text(expectedTag), findsOneWidget);
    });

    testWidgets('should not accept non-alphanum characters', (tester) async {
      const tagsField = TagsField();
      const nonAlphanumChars = r' ~!@#$%^&*()-+={}[]|\:;<,>.?/';

      await pumpProviderScoped(tester, tagsField);
      await tester.tap(find.byType(TagsField));
      await tester.pumpAndSettle();

      for (final character in nonAlphanumChars.characters) {
        await _addTag(tester: tester, tag: character);
        expect(find.text(character), findsNothing);
      }
    });
  });

  group('TextField Submit - ', () {
    testWidgets('should not accept empty string input', (tester) async {
      final controller = TagsEditingController();
      final tagsField = TagsField(controller: controller, maxTags: 1);
      const fakeEmptyTag = '';

      await _pumpWithTag(field: tagsField, tester: tester, tag: fakeEmptyTag);

      expect(controller.tags, isEmpty);
    });

    testWidgets('should submit when input space character', (tester) async {
      const tagsField = TagsField(maxTags: 1);
      const fakeTag = 'Tag';

      await _pumpWithTag(field: tagsField, tester: tester, tag: '$fakeTag ');

      expect(find.text(fakeTag.toUpperCase()), findsOneWidget);
    });

    testWidgets('should submit when input comma character', (tester) async {
      const tagsField = TagsField(maxTags: 1);
      const fakeTag = 'Tag';

      await _pumpWithTag(field: tagsField, tester: tester, tag: '$fakeTag,');

      expect(find.text(fakeTag.toUpperCase()), findsOneWidget);
    });

    testWidgets('should respect maxTags limit', (tester) async {
      const tagsField = TagsField(maxTags: 1);
      const firstTag = 'First';
      const invalidTag = 'Invalid';

      await _pumpWithTag(field: tagsField, tester: tester, tag: firstTag);
      await _addTag(tester: tester, tag: invalidTag);

      expect(find.text(firstTag.toUpperCase()), findsOneWidget);
      expect(find.text(invalidTag.toUpperCase()), findsNothing);
    });
  });

  group('Tags Units - ', () {
    testWidgets('should remove tag when tapping on it', (tester) async {
      const tagsField = TagsField();
      const fakeTag = 'TAG';

      await _pumpWithTag(field: tagsField, tester: tester, tag: fakeTag);
      await tester.tap(find.text(fakeTag).last);
      await tester.pumpAndSettle();

      expect(find.text(fakeTag), findsNothing);
    });
  });

  group('Helper Text - ', () {
    testWidgets('should update helper text when adding a tag', (tester) async {
      const maxTagsAmount = 3;
      const tagsField = TagsField(maxTags: maxTagsAmount);
      const fakeTag = 'TAG';
      final expectedHelperText = string.tagsAmount(1, maxTagsAmount);

      await _pumpWithTag(field: tagsField, tester: tester, tag: fakeTag);

      expect(find.text(expectedHelperText), findsOneWidget);
    });

    testWidgets('should update helper text when removing an existing tag', (tester) async {
      const maxTagsAmount = 3;
      const tagsField = TagsField(maxTags: maxTagsAmount);
      const fakeTag = 'TAG';
      final firstExpectedHelperText = string.tagsAmount(1, maxTagsAmount);
      final secondExpectedHelperText = string.tagsAmount(0, maxTagsAmount);

      await _pumpWithTag(field: tagsField, tester: tester, tag: fakeTag);
      expect(find.text(firstExpectedHelperText), findsOneWidget);

      await tester.tap(find.text(fakeTag).last);
      await tester.pumpAndSettle();
      expect(find.text(secondExpectedHelperText), findsOneWidget);
    });
  });

  group('Error State - ', () {
    testWidgets('error text should precede helper text', (tester) async {
      const fakeErrorText = 'Error Text';
      const tagsField = TagsField(errorText: fakeErrorText);

      await pumpProviderScoped(tester, tagsField);

      expect(find.text(fakeErrorText), findsOneWidget);
    });

    testWidgets('should add error border when error text is not null', (tester) async {
      const fakeErrorText = 'Error Text';
      const tagsField = TagsField(errorText: fakeErrorText);
      // ignore: invalid_use_of_protected_member
      final expectedColor = ThemeController().state.destructiveSwatch;

      await pumpProviderScoped(tester, tagsField);

      final wrapperContainer = find.byType(Container).first.evaluate().single.widget as Container;
      final containerDecoration = wrapperContainer.decoration! as BoxDecoration;
      final containerBorder = containerDecoration.border! as Border;

      expect(containerBorder.top.color, expectedColor);
      expect(containerBorder.right.color, expectedColor);
      expect(containerBorder.bottom.color, expectedColor);
      expect(containerBorder.left.color, expectedColor);
    });
  });

  group('TagsController - ', () {
    testWidgets('should add tag to the UI when updating the controller', (tester) async {
      const firstFakeTag = 'FIRST_TAG';
      const secondFakeTag = 'SECOND_TAG';
      final controller = TagsEditingController(tags: [firstFakeTag]);
      final tagsField = TagsField(controller: controller);

      await pumpProviderScoped(tester, tagsField);
      expect(find.text(firstFakeTag), findsOneWidget);
      expect(find.text(secondFakeTag), findsNothing);

      controller.tags = [firstFakeTag, secondFakeTag];
      await tester.pumpAndSettle();

      expect(find.text(firstFakeTag), findsOneWidget);
      expect(find.text(secondFakeTag), findsOneWidget);
    });
  });
}

/// Pumps [field] and calls [_addTag] using [tag].
Future<void> _pumpWithTag({required TagsField field, required WidgetTester tester, required String tag}) async {
  await pumpProviderScoped(tester, field);
  await tester.tap(find.byType(TagsField));
  await tester.pumpAndSettle();

  await _addTag(tester: tester, tag: tag);
}

/// Adds [tag] to an already pumped [TagsField].
Future<void> _addTag({required WidgetTester tester, required String tag}) async {
  await tester.enterText(find.byType(TextField).last, tag);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
