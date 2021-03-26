import 'dart:convert';
import 'dart:io';

const _path = 'test/fixtures';

Map<String, dynamic> _readFixture(String name) =>
    jsonDecode(File('$_path/$name').readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> cardExecution() => _readFixture('card_execution.json');
Map<String, dynamic> cardBlock() => _readFixture('card_block.json');
Map<String, dynamic> card() => _readFixture('card.json');
Map<String, dynamic> deck() => _readFixture('deck.json');
Map<String, dynamic> resource() => _readFixture('resource.json');
