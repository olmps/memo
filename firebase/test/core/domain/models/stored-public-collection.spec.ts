import { storedCollectionSchema } from "#domain/models/collection";
import { newRawStoredCollection } from "#test/core/data/schemas/collections-fakes";
import { ModelTester, ValidationProperties } from "#test/entity-tester";

describe("PublicCollection Validation", () => {
  const properties: ValidationProperties = {
    required: ["memosAmount", "memosOrder"],
    array: ["memosOrder"],
    uniqueItems: new Map<string, any[]>([["memosOrder", ["id1", "id1", "id1"]]]),
    incorrectTypes: new Map<string, unknown>([
      ["memosAmount", "string"],
      ["memosOrder", "string"],
    ]),
  };

  const tester = new ModelTester({
    schema: storedCollectionSchema,
    entityConstructor: newRawStoredCollection,
    properties: properties,
  });

  tester.runTests();
});
