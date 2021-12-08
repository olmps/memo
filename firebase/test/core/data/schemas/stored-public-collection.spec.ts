import { SchemaTester, ValidationProperties } from "#test/entity-tester";
import { newRawStoredCollection } from "./collections-fakes";

describe("Stored Public Collection Schema Validation", () => {
  const properties: ValidationProperties = {
    required: ["memosAmount", "memosOrder"],
    array: ["memosOrder"],
    uniqueItems: new Map<string, any[]>([["memosOrder", ["id1", "id1", "id1"]]]),
    incorrectTypes: new Map<string, any>([
      ["memosAmount", "string"],
      ["memosOrder", "string"],
    ]),
  };

  const tester = new SchemaTester({
    schema: "stored-public-collection",
    entityConstructor: newRawStoredCollection,
    properties: properties,
  });

  tester.runTests();
});
