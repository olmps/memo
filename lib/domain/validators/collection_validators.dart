import 'package:memo/core/faults/exceptions/validation_exception.dart';

const collectionNameMaxLength = 20;

void validateCollectionName(String name) {
  if (name.isEmpty) {
    throw ValidationException.emptyField();
  } else if (name.length > collectionNameMaxLength) {
    throw ValidationException.fieldLengthExceeded(collectionNameMaxLength);
  }
}

const collectionDescriptionMaxLength = 3000;

void validateCollectionDescription(String description) {
  if (description.isEmpty) {
    throw ValidationException.emptyField();
  } else if (description.length > collectionDescriptionMaxLength) {
    throw ValidationException.fieldLengthExceeded(collectionDescriptionMaxLength);
  }
}

const collectionTagMaxLength = 15;
final collectionTagRegex = RegExp(r'^[a-zA-Z0-9_ ,]*$');
