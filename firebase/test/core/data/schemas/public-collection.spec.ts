import Ajv2020 from "ajv/dist/2020";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { doesNotThrow, throws } from "assert";
import SerializationError from "#faults/errors/serialization-error";
import { newRawContributor, newRawLocalCollection, newRawResource } from "./collections-fakes";
import { CollectionResourceType } from "#domainmodels/collection";

describe("Public Collection Schema Validation", () => {
  const validator = new SchemaValidator(new Ajv2020());

  describe("Root Properties - ", () => {
    const requiredProperties = ["id", "name", "description", "tags", "category", "contributors", "resources", "memos"];
    const optionalProperties = ["locale"];
    const arrayProperties = ["tags", "contributors", "resources", "memos"];
    const stringProperties = ["id", "name", "description", "category"];
    // Maps an array property to a list of repeated items.
    const nonRepeatableArrayProperties = new Map<string, any[]>([
      ["tags", ["Tag", "Tag"]],
      ["contributors", [newRawContributor(), newRawContributor()]],
      ["resources", [newRawResource(), newRawResource()]],
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
    ]);

    it("should validate raw collection structure", () => {
      const rawCollection = newRawLocalCollection();

      doesNotThrow(() => validator.validateObject("local-public-collection", rawCollection));
    });

    it("should throw when a required property is not set", () => {
      for (const requiredProperty of requiredProperties) {
        const rawCollection = newRawLocalCollection();

        delete rawCollection[requiredProperty];

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should not throw when a optional property is not set", () => {
      for (const optionalProperty of optionalProperties) {
        const rawCollection = newRawLocalCollection();

        delete rawCollection[optionalProperty];

        doesNotThrow(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should throw when a required array is empty", () => {
      for (const arrayProperty of arrayProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection[arrayProperty] = [];

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should throw when assigning incorrect type to a property", () => {
      for (const incorrectPropertyEntry of incorrectPropertiesTypes) {
        const property = incorrectPropertyEntry[0];
        const incorrectType = incorrectPropertyEntry[1];
        const rawCollection = newRawLocalCollection();

        rawCollection[property] = incorrectType;

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should throw when array has repeated items", () => {
      for (const repeatedProperty of nonRepeatableArrayProperties) {
        const property = repeatedProperty[0];
        const repeatedItems = repeatedProperty[1];
        const rawCollection = newRawLocalCollection();

        rawCollection[property] = repeatedItems;

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should throw when a string property is empty", () => {
      for (const stringProperty of stringProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection[stringProperty] = "";

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });
  });

  describe("Contributors - ", () => {
    const requiredProperties = ["name", "url", "avatarUrl"];
    const stringProperties = ["name", "url", "avatarUrl"];
    const urlProperties = ["url", "avatarUrl"];

    it("should throw when a required property is not set", () => {
      for (const requiredProperty of requiredProperties) {
        const rawCollection = newRawLocalCollection();

        delete rawCollection.contributors[0][requiredProperty];

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should throw when a string property is empty", () => {
      for (const stringProperty of stringProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection.contributors[0][stringProperty] = "";

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should throw when an url property doesn't have valid format", () => {
      for (const urlProperty of urlProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection.contributors[0][urlProperty] = "invalidUrlFormat";

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });
  });

  describe("Resources - ", () => {
    const requiredProperties = ["description", "type", "url"];
    const stringProperties = ["description", "type", "url"];
    const urlProperties = ["url"];

    it("should throw when a required property is not set", () => {
      for (const requiredProperty of requiredProperties) {
        const rawCollection = newRawLocalCollection();

        delete rawCollection.resources[0][requiredProperty];

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should throw when a string property is empty", () => {
      for (const stringProperty of stringProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection.resources[0][stringProperty] = "";

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should throw when an url property doesn't have valid format", () => {
      for (const urlProperty of urlProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection.resources[0][urlProperty] = "invalidUrlFormat";

        throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("should accept allowed resource type", () => {
      const allowedTypes = Object.values(CollectionResourceType);

      for (const type of allowedTypes) {
        const rawCollection = newRawLocalCollection();

        rawCollection.resources[0]["type"] = type;

        doesNotThrow(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
      }
    });

    it("show throw when using unexpected resource type", () => {
      const rawCollection = newRawLocalCollection();

      rawCollection.resources[0]["type"] = "unexpectedType";

      throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
    });
  });
});
