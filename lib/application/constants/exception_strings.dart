import 'package:memo/core/faults/exceptions/base_exception.dart';
import 'package:memo/core/faults/exceptions/validation_exception.dart';

/// Returns a locale-suitable description for the following [exception].
String descriptionForException(BaseException exception) {
  switch (exception.type) {
    case ExceptionType.emptyField:
      return 'Este campo é obrigatório';
    case ExceptionType.fieldLengthExceeded:
      final validationException = exception as ValidationException;
      return 'Este campo tem limite máximo de ${validationException.amount!} caracteres';

    case ExceptionType.failedToOpenUrl:
      return 'Algo deu errado ao tentar abrir o link!';
    default:
      return 'Algo deu errado. Por favor tente novamente';
  }
}
