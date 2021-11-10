import 'package:mocktail/mocktail.dart';

final question = [
  {'question': '?'}
];
final answer = [
  {'answer': '!'}
];

class MockCallbackFunction extends Mock {
  void call();
}
