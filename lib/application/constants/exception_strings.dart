import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Returns a locale-suitable description for the following [exception].
String descriptionForException(BaseException exception) {
  switch (exception.type) {
    default:
      return 'Algo deu errado. Por favor tente novamente';
  }
}
