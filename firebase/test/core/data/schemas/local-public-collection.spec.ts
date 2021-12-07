import { newRawLocalCollection, newRawMemo } from "./collections-fakes";
import { ValidationProperties, SchemaValidatorBuilder } from "#test/validator";

describe("Local Public Collection Schema Validation", () => {
  const properties: ValidationProperties = {
    required: ["memos"],
    array: ["memos"],
    uniqueItems: new Map<string, any[]>([["memos", [newRawMemo(), newRawMemo()]]]),
    incorrectTypes: new Map<string, any>([["memos", "string"]]),
  };

  const validator = new SchemaValidatorBuilder({
    schema: "local-public-collection",
    entityConstructor: newRawLocalCollection,
    properties: properties,
  });

  validator.validate();
});
