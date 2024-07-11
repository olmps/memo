import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/product_info_serializer.dart';
import 'package:memo/domain/models/product_info.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = ProductInfoSerializer();
  final testProductInfo = ProductInfo(
    id: '',
    price: 0.0,
  );

  test('ProductInfoSerializer should correctly encode/decode a ProductInfo', () {
    final rawProductInfo = fixtures.productInfo();

    final decodedProductInfo = serializer.from(rawProductInfo);
    expect(decodedProductInfo, testProductInfo);

    final encodedProductInfo = serializer.to(decodedProductInfo);
    expect(encodedProductInfo, rawProductInfo);
  });

  test('ProductInfoSerializer should fail to decode without required properties', () {
    final rawProductInfo = fixtures.productInfo()
      ..[ProductInfoKeys.id] = ''
      ..[ProductInfoKeys.price] = 0.0;

    final decodedProductInfo = serializer.from(rawProductInfo);

    final allPropsProductInfo = ProductInfo(id: '', price: 0.0);

    expect(decodedProductInfo, allPropsProductInfo);
    expect(rawProductInfo, serializer.to(decodedProductInfo));
  });
}
