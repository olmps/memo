import 'package:memo/domain/models/collection.dart';

class CollectionStatus {
  CollectionStatus(this.collection, this.memoryStability);

  final Collection collection;
  final double? memoryStability;
}
