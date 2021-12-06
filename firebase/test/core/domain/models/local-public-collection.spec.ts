import ValidationError from "#faults/errors/validation-error";
import { localCollectionSchema } from "#domain/models/collection";
import { doesNotThrow, throws } from "assert";
import { validate } from "#utils/validate";
import { newRawLocalCollection, newRawMemo } from "#test/core/data/schemas/collections-fakes";

describe("PublicCollection Validation", () => {
  const requiredProperties = ["memos"];
  const optionalProperties: string[] = [];
  const incorrectPropertiesTypes = new Map<string, any>([["memos", "string"]]);

  const arrayProperties = ["memos"];
  const stringProperties: string[] = [];
  // Maps an array property to a list of repeated items.
  const nonRepeatableArrayProperties = new Map<string, any[]>([["memos", [newRawMemo(), newRawMemo()]]]);
  // Maps strings properties to their maximum allowed length
  const stringPropertiesLengths = new Map<string, any>([]);

  it("should throw when required property is not set", () => {
    for (const requiredProperty of requiredProperties) {
      const rawCollection = newRawLocalCollection();

      delete rawCollection[requiredProperty];

      throws(() => validate(localCollectionSchema, rawCollection), ValidationError);
    }
  });

  it("should not throw when a optional property is not set", () => {
    for (const optionalProperty of optionalProperties) {
      const rawCollection = newRawLocalCollection();

      delete rawCollection[optionalProperty];

      doesNotThrow(() => validate(localCollectionSchema, rawCollection), ValidationError);
    }
  });

  it("should throw when a required array is empty", () => {
    for (const arrayProperty of arrayProperties) {
      const rawCollection = newRawLocalCollection();

      rawCollection[arrayProperty] = [];

      throws(() => validate(localCollectionSchema, rawCollection), ValidationError);
    }
  });

  it("should throw when assigning incorrect type to a property", () => {
    for (const incorrectPropertyEntry of incorrectPropertiesTypes) {
      const property = incorrectPropertyEntry[0];
      const incorrectType = incorrectPropertyEntry[1];
      const rawCollection = newRawLocalCollection();

      rawCollection[property] = incorrectType;

      throws(() => validate(localCollectionSchema, rawCollection), ValidationError);
    }
  });

  it("should throw when array has repeated items", () => {
    for (const repeatedProperty of nonRepeatableArrayProperties) {
      const property = repeatedProperty[0];
      const repeatedItems = repeatedProperty[1];
      const rawCollection = newRawLocalCollection();

      rawCollection[property] = repeatedItems;

      throws(() => validate(localCollectionSchema, rawCollection), ValidationError);
    }
  });

  it("should throw when a required string is empty", () => {
    for (const stringProperty of stringProperties) {
      const rawCollection = newRawLocalCollection();

      rawCollection[stringProperty] = "";

      throws(() => validate(localCollectionSchema, rawCollection), ValidationError);
    }
  });

  it("should throw when a string is greater than the max characters allowed", () => {
    for (const stringProperty of stringPropertiesLengths) {
      const property = stringProperty[0];
      const maxCharsAmount = stringProperty[1];
      const rawCollection = newRawLocalCollection();

      rawCollection[property] = "a".repeat(maxCharsAmount + 1);

      throws(() => validate(localCollectionSchema, rawCollection), ValidationError);
    }
  });
});
