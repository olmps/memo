import 'package:equatable/equatable.dart';

class ProductInfo with EquatableMixin {
  ProductInfo({
    required this.id,
    required this.price,
  });

  final String id;
  final double price;

  @override
  List<Object?> get props => [id, price];
}
