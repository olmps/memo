import Ajv2020 from "ajv/dist/2020";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { doesNotThrow, throws } from "assert";
import SerializationError from "#faults/errors/serialization-error";

describe("Local Public Collection Schema Validation", () => {
  const validator = new SchemaValidator(new Ajv2020());
  const requiredProperties = ["id", "name", "description", "tags", "category", "contributors", "resources", "memos"];
  const optionalProperties = ["locale"];
  const arrayProperties = ["tags", "contributors", "resources", "memos"];
  // Maps an array property to a list of repeated items.
  const nonRepeatableArrayProperties = new Map<string, any[]>([
    ["tags", [_newRawTag(), _newRawTag()]],
    ["contributors", [_newRawContributor(), _newRawContributor()]],
    ["resources", [_newRawResource(), _newRawResource()]],
    ["memos", [_newRawMemo(), _newRawMemo()]],
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
    ["memos", "string"],
  ]);

  it("should validate raw collection structure", () => {
    const rawCollection = _newRawLocalCollection();

    doesNotThrow(() => validator.validateObject("local-public-collection", rawCollection));
  });

  it("should throw when a required property is not set", () => {
    for (const requiredProperty of requiredProperties) {
      const rawCollection = _newRawLocalCollection();

      delete rawCollection[requiredProperty];

      throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
    }
  });

  it("should not throw when a optional property is not set", () => {
    for (const optionalProperty of optionalProperties) {
      const rawCollection = _newRawLocalCollection();

      delete rawCollection[optionalProperty];

      doesNotThrow(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
    }
  });

  it("should throw when a required array is empty", () => {
    for (const arrayProperty of arrayProperties) {
      const rawCollection = _newRawLocalCollection();

      rawCollection[arrayProperty] = [];

      throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
    }
  });

  it("should throw when assigning incorrect type to a property", () => {
    for (const incorrectPropertyEntry of incorrectPropertiesTypes) {
      const property = incorrectPropertyEntry[0];
      const incorrectType = incorrectPropertyEntry[1];
      const rawCollection = _newRawLocalCollection();

      rawCollection[property] = incorrectType;

      throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
    }
  });

  it("should throw when array has repeated items", () => {
    for (const repeatedProperty of nonRepeatableArrayProperties) {
      const property = repeatedProperty[0];
      const repeatedItems = repeatedProperty[1];
      const rawCollection = _newRawLocalCollection();

      rawCollection[property] = repeatedItems;

      throws(() => validator.validateObject("local-public-collection", rawCollection), SerializationError);
    }
  });
});

function _newRawTag(props?: { id?: string; name?: string }): any {
  return { id: props?.id ?? "id", name: props?.name ?? "Tag Name" };
}

function _newRawResource(props?: { type?: string; url?: string; description?: string }): any {
  return {
    type: props?.type ?? "article",
    url: props?.url ?? "url",
    description: props?.description ?? "description",
  };
}

function _newRawContributor(props?: { name?: string; url?: string; avatar?: string }): any {
  return {
    name: props?.name ?? "name",
    url: props?.url ?? "url",
    avatar: props?.avatar ?? "avatar",
  };
}

function _newRawMemo(props?: { id?: string; question?: any[]; answer?: any[] }): any {
  return {
    id: props?.id ?? "any",
    question: props?.question ?? [{ insert: "content" }],
    answer: props?.answer ?? [{ insert: "content" }],
  };
}

function _newRawLocalCollection(): any {
  return {
    id: "any",
    name: "name",
    tags: [_newRawTag({ id: "id1", name: "Tag 1" }), _newRawTag({ id: "id2", name: "Tag 2" })],
    category: "Collection Category",
    description: "Collection Description",
    locale: "ptBR",
    contributors: [_newRawContributor()],
    resources: [_newRawResource()],
    memos: [_newRawMemo()],
  };
}
