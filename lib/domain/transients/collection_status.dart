import 'package:memo/domain/models/collection.dart';

class CollectionStatus {
  CollectionStatus(this.collection, this.memoryRecall);

  final Collection collection;
  final double? memoryRecall;
}
