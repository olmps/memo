import Ajv2020 from "ajv/dist/2020";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { doesNotThrow, throws } from "assert";
import SerializationError from "#faults/errors/serialization-error";

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
    const rawCollection = _newRawStoredCollection();

    doesNotThrow(() => validator.validateObject("stored-public-collection", rawCollection));
  });

  it("should throw when a required property is not set", () => {
    for (const requiredProperty of requiredProperties) {
      const rawCollection = _newRawStoredCollection();

      delete rawCollection[requiredProperty];

      throws(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });

  it("should not throw when a optional property is not set", () => {
    for (const optionalProperty of optionalProperties) {
      const rawCollection = _newRawStoredCollection();

      delete rawCollection[optionalProperty];

      doesNotThrow(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });

  it("should thrown when a required array is empty", () => {
    for (const arrayProperty of arrayProperties) {
      const rawCollection = _newRawStoredCollection();

      rawCollection[arrayProperty] = [];

      throws(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });

  it("should thrown when assigning incorrect type to a property", () => {
    for (const incorrectPropertyEntry of incorrectPropertiesTypes) {
      const property = incorrectPropertyEntry[0];
      const incorrectType = incorrectPropertyEntry[1];
      const rawCollection = _newRawStoredCollection();

      rawCollection[property] = incorrectType;

      throws(() => validator.validateObject("stored-public-collection", rawCollection), SerializationError);
    }
  });
});

function _newRawStoredCollection(): any {
  const rawContributor = {
    name: "name",
    url: "url",
    avatar: "avatarUrl",
  };
  const rawResource = {
    type: "article",
    url: "url",
    description: "description",
  };

  return {
    id: "any",
    name: "name",
    tags: [
      { id: "id1", name: "Tag 1" },
      { id: "id2", name: "Tag 2" },
    ],
    category: "Collection Category",
    description: "Collection Description",
    locale: "ptBR",
    contributors: [rawContributor],
    resources: [rawResource],
    memosAmount: 3,
    memosOrder: ["id1", "id2", "id3"],
  };
}
