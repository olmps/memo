import 'package:memo/data/repositories/deck_repository.dart';
import 'package:memo/domain/models/deck.dart';

abstract class DeckServices {
  Future<List<Deck>> getAllDecks();
}

class DeckServicesImpl implements DeckServices {
  DeckServicesImpl(this.repo);

  final DeckRepository repo;

  @override
  Future<List<Deck>> getAllDecks() => repo.getAllDecks();
}
