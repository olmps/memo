import ValidationError from "#faults/errors/validation-error";
import { publicCollectionSchema, maxDescriptionLength, CollectionResourceType } from "#domain/models/collection";
import { doesNotThrow, throws } from "assert";
import { defaultMaxStringLength, validate } from "#utils/validate";
import { newRawContributor, newRawLocalCollection, newRawResource } from "#test/core/data/schemas/collections-fakes";

describe("PublicCollection Validation", () => {
  const requiredProperties = ["id", "name", "description", "tags", "category", "contributors", "resources"];
  const optionalProperties = ["locale"];
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

  const arrayProperties = ["tags", "contributors", "resources"];
  const stringProperties = ["id", "name", "description", "category"];
  // Maps an array property to a list of repeated items.
  const nonRepeatableArrayProperties = new Map<string, any[]>([
    ["tags", ["Tag", "Tag"]],
    ["contributors", [newRawContributor(), newRawContributor()]],
    ["resources", [newRawResource(), newRawResource()]],
  ]);
  // Maps strings properties to their maximum allowed length
  const stringPropertiesLengths = new Map<string, any>([
    ["id", defaultMaxStringLength],
    ["name", defaultMaxStringLength],
    ["description", maxDescriptionLength],
    ["category", defaultMaxStringLength],
  ]);

  describe("Root Properties - ", () => {
    it("should throw when required property is not set", () => {
      for (const requiredProperty of requiredProperties) {
        const rawCollection = newRawLocalCollection();

        delete rawCollection[requiredProperty];

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should not throw when a optional property is not set", () => {
      for (const optionalProperty of optionalProperties) {
        const rawCollection = newRawLocalCollection();

        delete rawCollection[optionalProperty];

        doesNotThrow(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when a required array is empty", () => {
      for (const arrayProperty of arrayProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection[arrayProperty] = [];

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when assigning incorrect type to a property", () => {
      for (const incorrectPropertyEntry of incorrectPropertiesTypes) {
        const property = incorrectPropertyEntry[0];
        const incorrectType = incorrectPropertyEntry[1];
        const rawCollection = newRawLocalCollection();

        rawCollection[property] = incorrectType;

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when array has repeated items", () => {
      for (const repeatedProperty of nonRepeatableArrayProperties) {
        const property = repeatedProperty[0];
        const repeatedItems = repeatedProperty[1];
        const rawCollection = newRawLocalCollection();

        rawCollection[property] = repeatedItems;

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when a required string is empty", () => {
      for (const stringProperty of stringProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection[stringProperty] = "";

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when a string is greater than the max characters allowed", () => {
      for (const stringProperty of stringPropertiesLengths) {
        const property = stringProperty[0];
        const maxCharsAmount = stringProperty[1];
        const rawCollection = newRawLocalCollection();

        rawCollection[property] = "a".repeat(maxCharsAmount + 1);

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });
  });

  describe("Contributors - ", () => {
    const requiredProperties = ["name", "url", "avatarUrl"];
    const stringProperties = ["name", "url", "avatarUrl"];
    const urlProperties = ["url", "avatarUrl"];
    // Maps strings properties to their maximum allowed length
    const stringPropertiesLengths = new Map<string, any>([["name", defaultMaxStringLength]]);

    it("should throw when a required property is not set", () => {
      for (const requiredProperty of requiredProperties) {
        const rawCollection = newRawLocalCollection();

        delete rawCollection.contributors[0][requiredProperty];

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when a string property is empty", () => {
      for (const stringProperty of stringProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection.contributors[0][stringProperty] = "";

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when an url property doesn't have valid format", () => {
      for (const urlProperty of urlProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection.contributors[0][urlProperty] = "invalidUrlFormat";

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when a string is greater than the max characters allowed", () => {
      for (const stringProperty of stringPropertiesLengths) {
        const property = stringProperty[0];
        const maxCharsAmount = stringProperty[1];
        const rawCollection = newRawLocalCollection();

        rawCollection[property] = "a".repeat(maxCharsAmount + 1);

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });
  });

  describe("Resources - ", () => {
    const requiredProperties = ["description", "type", "url"];
    const stringProperties = ["description", "type", "url"];
    const urlProperties = ["url"];
    // Maps strings properties to their maximum allowed length
    const stringPropertiesLengths = new Map<string, any>([["description", maxDescriptionLength]]);

    it("should throw when a required property is not set", () => {
      for (const requiredProperty of requiredProperties) {
        const rawCollection = newRawLocalCollection();

        delete rawCollection.resources[0][requiredProperty];

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when a string property is empty", () => {
      for (const stringProperty of stringProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection.resources[0][stringProperty] = "";

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when an url property doesn't have valid format", () => {
      for (const urlProperty of urlProperties) {
        const rawCollection = newRawLocalCollection();

        rawCollection.resources[0][urlProperty] = "invalidUrlFormat";

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should throw when a string is greater than the max characters allowed", () => {
      for (const stringProperty of stringPropertiesLengths) {
        const property = stringProperty[0];
        const maxCharsAmount = stringProperty[1];
        const rawCollection = newRawLocalCollection();

        rawCollection.resources[0][property] = "a".repeat(maxCharsAmount + 1);

        throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("should accept allowed resource type", () => {
      const allowedTypes = Object.values(CollectionResourceType);

      for (const type of allowedTypes) {
        const rawCollection = newRawLocalCollection();

        rawCollection.resources[0]["type"] = type;

        doesNotThrow(() => validate(publicCollectionSchema, rawCollection), ValidationError);
      }
    });

    it("show throw when using unexpected resource type", () => {
      const rawCollection = newRawLocalCollection();

      rawCollection.resources[0]["type"] = "unexpectedType";

      throws(() => validate(publicCollectionSchema, rawCollection), ValidationError);
    });
  });
});
