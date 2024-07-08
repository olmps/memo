import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/product_info.dart';

class ProductInfoKeys {
  static const id = 'productId';
  static const price = 'price';
}

class ProductInfoSerializer implements Serializer<ProductInfo, Map<String, dynamic>> {
  @override
  ProductInfo from(Map<String, dynamic> json) {
    final id = json[ProductInfoKeys.id] as String?;
    final price = json[ProductInfoKeys.price] as double?;

    return ProductInfo(
      id: id ?? '',
      price: price ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> to(ProductInfo productInfo) => <String, dynamic>{
        ProductInfoKeys.id: productInfo.id,
        ProductInfoKeys.price: productInfo.price,
      };
}
