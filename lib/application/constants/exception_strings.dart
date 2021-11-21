import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Returns a locale-suitable description for the following [exception].
String descriptionForException(BaseException exception) {
  if (exception.message != null) {
    return exception.message!;
  }

  switch (exception.type) {
    case ExceptionType.emptyField:
      return 'Este campo é obrigatório';
    case ExceptionType.fieldLengthExceeded:
      return 'Limite máximo de caracteres ultrapassado';

    case ExceptionType.failedToOpenUrl:
      return 'Algo deu errado ao tentar abrir o link!';
    default:
      return 'Algo deu errado. Por favor tente novamente';
  }
}
