import Ajv2020 from "ajv/dist/2020";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { doesNotThrow, throws } from "assert";
import SerializationError from "#faults/errors/serialization-error";
import { newRawContributor, newRawResource, newRawStoredCollection } from "./collections-fakes";

describe("Stored Public Collection Schema Validation", () => {
  const validator = new SchemaValidator(new Ajv2020());
  const requiredProperties = [
    "id",
    "name",
    "description",
    "tags",
    "category",
    "contributors",
    "resources",
    "memosAmount",
    "memosOrder",
  ];
  const optionalProperties = ["locale"];
  const arrayProperties = ["tags", "contributors", "resources", "memosOrder"];
  // Maps an array property to a list of repeated items.
  const nonRepeatableArrayProperties = new Map<string, any[]>([
    ["tags", ["Tag", "Tag"]],
    ["contributors", [newRawContributor(), newRawContributor()]],
    ["resources", [newRawResource(), newRawResource()]],
    ["memosOrder", ["id1", "id1", "id1"]],
  ]);

  // Maps a property to a type that couldn't be associated to it.
  const incorrectPropertiesTypes = new Map<string, any>([
    ["id", true],
    ["name", true],
    ["description", true],
    ["tags", "string"],
    ["category", true],
    ["contributors", "string"],
    ["resources", "string"],
    ["locale", 0],
    ["memosAmount", "string"],
    ["memosOrder", "string"],
  ]);

  it("should validate raw collection structure", () => {
    const rawCollection = newRawStoredCollection();

    doesNotThrow(() => validator.validateObject("stored-public-collection", rawCollection));
  });

  it("should throw when a required property is not set", () => {
    for (const requiredProperty of requiredProperties) {
      const rawCollection = newRawStoredCollection();

      delete rawCollection[requiredProperty];

      throws(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });

  it("should not throw when a optional property is not set", () => {
    for (const optionalProperty of optionalProperties) {
      const rawCollection = newRawStoredCollection();

      delete rawCollection[optionalProperty];

      doesNotThrow(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });

  it("should throw when a required array is empty", () => {
    for (const arrayProperty of arrayProperties) {
      const rawCollection = newRawStoredCollection();

      rawCollection[arrayProperty] = [];

      throws(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });

  it("should throw when assigning incorrect type to a property", () => {
    for (const incorrectPropertyEntry of incorrectPropertiesTypes) {
      const property = incorrectPropertyEntry[0];
      const incorrectType = incorrectPropertyEntry[1];
      const rawCollection = newRawStoredCollection();

      rawCollection[property] = incorrectType;

      throws(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });

  it("should throw when array has repeated items", () => {
    for (const repeatedProperty of nonRepeatableArrayProperties) {
      const property = repeatedProperty[0];
      const repeatedItems = repeatedProperty[1];
      const rawCollection = newRawStoredCollection();

      rawCollection[property] = repeatedItems;

      throws(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });
});
