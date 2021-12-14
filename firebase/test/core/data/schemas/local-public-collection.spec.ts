import { newRawLocalCollection, newRawMemo } from "./collections-fakes";
import { ValidationProperties, SchemaTester } from "#test/entity-tester";

describe("Local Public Collection Schema Validation", () => {
  const properties: ValidationProperties = {
    required: ["memos"],
    array: ["memos"],
    uniqueItems: new Map<string, any[]>([["memos", [newRawMemo(), newRawMemo()]]]),
    incorrectTypes: new Map<string, any>([["memos", "string"]]),
  };

  const tester = new SchemaTester({
    schema: "local-public-collection",
    entityConstructor: newRawLocalCollection,
    properties: properties,
  });

  tester.runTests();
});
