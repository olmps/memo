import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
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

      expect(find.text(expectedTag), findsNWidgets(2));
    });

    testWidgets('should not accept non-alphanum characters', (tester) async {
      const tagsField = TagsField();
      const nonAlphanumChars = r' ~!@#$%^&*()-+={}[]|\:;<,>.?/';

      await pumpThemedProviderScoped(tester, tagsField);
      await tester.tap(find.byType(TagsField));
      await tester.pumpAndSettle();

      for (final character in nonAlphanumChars.characters) {
        await _addTag(field: tagsField, tester: tester, tag: character);
        expect(find.text(character), findsNothing);
      }
    });
  });

  group('TextField Submit - ', () {
    testWidgets('should submit when input space character', (tester) async {
      const tagsField = TagsField(maxTags: 1);
      const fakeTag = 'Tag';

      await _pumpWithTag(field: tagsField, tester: tester, tag: '$fakeTag ');

      expect(find.text(fakeTag.toUpperCase()), findsNWidgets(2));
    });

    testWidgets('should submit when input comma character', (tester) async {
      const tagsField = TagsField(maxTags: 1);
      const fakeTag = 'Tag';

      await _pumpWithTag(field: tagsField, tester: tester, tag: '$fakeTag,');

      expect(find.text(fakeTag.toUpperCase()), findsNWidgets(2));
    });

    testWidgets('should respect maxTags limit', (tester) async {
      const tagsField = TagsField(maxTags: 1);
      const firstTag = 'First';
      const invalidTag = 'Invalid';

      await _pumpWithTag(field: tagsField, tester: tester, tag: firstTag);
      await _addTag(field: tagsField, tester: tester, tag: invalidTag);

      expect(find.text(firstTag.toUpperCase()), findsNWidgets(2));
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

    testWidgets('should not remove tag when tapping on it in the collapsed field', (tester) async {
      const tagsField = TagsField();
      const fakeTag = 'TAG';

      await _pumpWithTag(field: tagsField, tester: tester, tag: fakeTag);

      await tester.tap(find.byType(CustomTextButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text(fakeTag).first);
      await tester.pumpAndSettle();

      expect(find.text(fakeTag), findsNWidgets(2));
    });
  });

  group('Tags Counter - ', () {
    testWidgets('should increment tag counter when adding a tag', (tester) async {
      const maxTagsAmount = 3;
      const tagsField = TagsField(maxTags: maxTagsAmount);
      const fakeTag = 'TAG';
      const expectedCounter = '1/$maxTagsAmount';

      await _pumpWithTag(field: tagsField, tester: tester, tag: fakeTag);

      expect(find.text(expectedCounter), findsOneWidget);
    });

    testWidgets('should decrease tag counter when adding a tag', (tester) async {
      const maxTagsAmount = 3;
      const tagsField = TagsField(maxTags: maxTagsAmount);
      const fakeTag = 'TAG';
      const firstExpectedCounter = '1/$maxTagsAmount';
      const secondExpectedCounter = '0/$maxTagsAmount';

      await _pumpWithTag(field: tagsField, tester: tester, tag: fakeTag);
      expect(find.text(firstExpectedCounter), findsOneWidget);

      await tester.tap(find.text(fakeTag).last);
      await tester.pumpAndSettle();
      expect(find.text(secondExpectedCounter), findsOneWidget);
    });
  });

  group('Suggestions List - ', () {
    testWidgets('should present loading while fetching suggestions', (tester) async {
      const fakeState = SuggestionsState(suggestions: [], isLoading: true);
      const tagsField = TagsField();

      await pumpThemedProviderScoped(tester, tagsField, [
        suggestionsController.state.overrideWithValue(fakeState),
      ]);
      await tester.tap(find.byType(TagsField));

      // TODO(Ggirotto)
      try {
        await tester.pumpAndSettle();
      } catch (_) {}

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should present list of suggestions when available', (tester) async {
      const suggestions = ['A', 'B', 'C'];
      const fakeState = SuggestionsState(suggestions: suggestions, isLoading: false);
      const tagsField = TagsField();

      await pumpThemedProviderScoped(tester, tagsField, [
        suggestionsController.state.overrideWithValue(fakeState),
      ]);
      await tester.tap(find.byType(TagsField));
      await tester.pumpAndSettle();

      for (final suggestion in suggestions) {
        expect(find.text(suggestion), findsOneWidget);
      }
    });

    testWidgets('should add suggestion to tags list when tapped', (tester) async {
      const suggestion = 'A';
      final fakeController = SuggestionsController()
        ..state = const SuggestionsState(suggestions: [suggestion], isLoading: false);
      const tagsField = TagsField();

      await pumpThemedProviderScoped(tester, tagsField, [
        suggestionsController.overrideWithValue(fakeController),
      ]);
      await tester.tap(find.byType(TagsField));
      await tester.pumpAndSettle();

      await tester.tap(find.text(suggestion));
      await tester.pumpAndSettle();

      // Expect two occurrences, the on in the modal list and the on in the tags field behind the modal
      expect(find.text(suggestion), findsNWidgets(2));
    });
  });

  group('TagsController - ', () {
    testWidgets('should add tag to the UI when updating the controller', (tester) async {
      const firstFakeTag = 'FIRST_TAG';
      const secondFakeTag = 'SECOND_TAG';
      final controller = StateProvider<List<String>>((_) => [firstFakeTag, secondFakeTag]);
      const tagsField = TagsField();

      await pumpThemedProviderScoped(tester, tagsField, [
        tagsController.overrideWithProvider(controller),
      ]);
      await tester.tap(find.byType(TagsField));
      await tester.pumpAndSettle();

      expect(find.text(firstFakeTag), findsNWidgets(2));
      expect(find.text(secondFakeTag), findsNWidgets(2));
    });
  });

  group('SuggestionsController - ', () {
    test('should emit loading state when calling loadSuggestions', () async {
      final controller = SuggestionsController();
      const searchTerm = 'search';

      expect(
        controller.stream,
        emits(const SuggestionsState(suggestions: [], isLoading: true, searchTerm: searchTerm)),
      );

      await controller.loadSuggestions(searchTerm);
    });

    test('should clear suggestions when calling clearSuggestions', () {
      const initialSuggestions = ['A', 'B', 'C'];
      const initialState = SuggestionsState(suggestions: initialSuggestions, isLoading: false);
      final controller = SuggestionsController()..state = initialState;

      expect(controller.state, initialState);
      expect(controller.stream, emits(const SuggestionsState(suggestions: [], isLoading: false)));

      controller.clearSuggestions();
    });
  });
}

/// TODO(ggirotto)
Future<void> _pumpWithTag({required TagsField field, required WidgetTester tester, String? tag}) async {
  await pumpThemedProviderScoped(tester, field);
  await tester.tap(find.byType(TagsField));
  await tester.pumpAndSettle();

  if (tag != null) {
    await _addTag(field: field, tester: tester, tag: tag);
  }
}

/// TODO(ggirotto)
Future<void> _addTag({required TagsField field, required WidgetTester tester, required String tag}) async {
  await tester.enterText(find.byType(TextField).last, tag);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
