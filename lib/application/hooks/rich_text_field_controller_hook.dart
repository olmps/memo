import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';

/// Creates a [RichTextFieldController] by sending initial selection, rich and plain text values.
///
/// It shares the same behavior as [useTextEditingController], i.e, changing the properties after the widget has been
/// built has no effect whatsoever.
///
/// See also:
/// - [useTextEditingController], which shares the same hook characteristics as this one, but creates a
/// [TextEditingController] instead.
/// - [RichTextFieldController], which this hook creates.
const useRichTextEditingController = _RichTextEditingControllerHookCreator();

class _RichTextEditingControllerHookCreator {
  const _RichTextEditingControllerHookCreator();

  /// Creates a [RichTextFieldController] that will be disposed automatically.
  ///
  /// The [richText], [plainText] and [selection] parameters can be used to set the initial values of the controller.
  RichTextFieldController call({String? richText, String? plainText, TextSelection? selection, List<Object?>? keys}) {
    return use(_RichTextEditingControllerHook(richText, plainText, selection, keys));
  }
}

class _RichTextEditingControllerHook extends Hook<RichTextFieldController> {
  const _RichTextEditingControllerHook(
    this.initialRichText,
    this.initialPlainText,
    this.initialSelection, [
    List<Object?>? keys,
  ]) : super(keys: keys);

  final String? initialRichText;
  final String? initialPlainText;
  final TextSelection? initialSelection;

  @override
  _RichTextEditingControllerHookState createState() {
    return _RichTextEditingControllerHookState();
  }
}

class _RichTextEditingControllerHookState extends HookState<RichTextFieldController, _RichTextEditingControllerHook> {
  late final _controller = RichTextFieldController(
    richText: hook.initialRichText,
    plainText: hook.initialPlainText,
    selection: hook.initialSelection,
  );

  @override
  RichTextFieldController build(BuildContext context) => _controller;

  @override
  void dispose() => _controller.dispose();

  @override
  String get debugLabel => 'useRichTextEditingController';
}
