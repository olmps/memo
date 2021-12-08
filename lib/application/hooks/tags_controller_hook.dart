import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/widgets/theme/tags_field.dart';

// Creates a [TagsController] by sending a initial lit of tags.
///
/// It shares the same behavior as [useTextEditingController], i.e, changing the properties after the widget has been
/// built has no effect whatsoever.
///
/// See also:
/// * [useTextEditingController], which shares the same hook characteristics as this one, but creates a
///   [TextEditingController] instead.
/// * [TagsEditingController], which this hook creates.
const useTagsController = _TagsControllerHookCreator();

class _TagsControllerHookCreator {
  const _TagsControllerHookCreator();

  /// Creates a [TagsEditingController] that will be disposed automatically.
  ///
  /// The [tags] parameter can be used to set the initial value of the controller.
  TagsEditingController call({List<String>? tags, List<Object?>? keys}) {
    return use(_TagsControllerHook(tags, keys));
  }
}

class _TagsControllerHook extends Hook<TagsEditingController> {
  const _TagsControllerHook(this.initialTags, [List<Object?>? keys]) : super(keys: keys);

  final List<String>? initialTags;

  @override
  _TagsControllerHookState createState() {
    return _TagsControllerHookState();
  }
}

class _TagsControllerHookState extends HookState<TagsEditingController, _TagsControllerHook> {
  late final _controller = TagsEditingController(tags: hook.initialTags);

  @override
  TagsEditingController build(BuildContext context) => _controller;

  @override
  void dispose() => _controller.dispose();

  @override
  String get debugLabel => 'useTagsController';
}
