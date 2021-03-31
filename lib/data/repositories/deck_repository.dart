import 'package:memo/domain/models/deck.dart';
import 'package:memo/data/serializers/deck_serializer.dart';
import 'package:memo/data/gateways/document_database_gateway.dart';

abstract class DeckRepository {
  Future<List<Deck>> getAllDecks();
}

class DeckRepositoryImpl implements DeckRepository {
  DeckRepositoryImpl(this._db);

  final DocumentDatabaseGateway _db;
  final _deckSerializer = DeckSerializer();
  final _deckStore = 'decks';

  @override
  Future<List<Deck>> getAllDecks() async {
    final rawDecks = await _db.getAll(store: _deckStore);
    return rawDecks.map(_deckSerializer.from).toList();
  }
}
