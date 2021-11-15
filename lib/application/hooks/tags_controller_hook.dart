import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/widgets/theme/tags_field.dart';

const useTagsController = _TagsControllerHookCreator();

class _TagsControllerHookCreator {
  const _TagsControllerHookCreator();

  /// Creates a [TagsController] that will be disposed automatically.
  ///
  /// The [tags] parameter can be used to set the initial value of the controller.
  TagsController call({List<String>? tags, List<Object?>? keys}) {
    return use(_TagsControllerHook(tags, keys));
  }
}

class _TagsControllerHook extends Hook<TagsController> {
  const _TagsControllerHook(this.initialTags, [List<Object?>? keys]) : super(keys: keys);

  final List<String>? initialTags;

  @override
  _TagsControllerHookState createState() {
    return _TagsControllerHookState();
  }
}

class _TagsControllerHookState extends HookState<TagsController, _TagsControllerHook> {
  late final _controller = TagsController(tags: hook.initialTags);

  @override
  TagsController build(BuildContext context) => _controller;

  @override
  void dispose() => _controller.dispose();

  @override
  String get debugLabel => 'useTagsController';
}
