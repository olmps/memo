import { localCollectionSchema } from "#domain/models/collection";
import { newRawLocalCollection, newRawMemo } from "#test/core/data/schemas/collections-fakes";
import { ModelTester, ValidationProperties } from "#test/entity-tester";

describe("PublicCollection Validation", () => {
  const properties: ValidationProperties = {
    required: ["memos"],
    array: ["memos"],
    incorrectTypes: new Map<string, unknown>([["memos", "string"]]),
    uniqueItems: new Map<string, unknown[]>([["memos", [newRawMemo(), newRawMemo()]]]),
  };

  const tester = new ModelTester({
    schema: localCollectionSchema,
    entityConstructor: newRawLocalCollection,
    properties: properties,
  });

  tester.runTests();
});
