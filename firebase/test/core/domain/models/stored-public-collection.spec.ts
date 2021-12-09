import * as assert from "assert";
import { storedCollectionSchema } from "#domain/models/collection";
import ValidationError from "#faults/errors/validation-error";
import { newRawStoredCollection } from "#test/core/data/schemas/collections-fakes";
import { ModelTester, ValidationProperties } from "#test/entity-tester";
import { validate } from "#utils/validate";

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

  it("should throw when memosOrder length differ from memosAmount", () => {
    const rawCollection = newRawStoredCollection();

    rawCollection["memosAmount"] = 1;
    rawCollection["memosOrder"] = ["1", "2"];

    assert.throws(() => validate(storedCollectionSchema, rawCollection), ValidationError);
  });
});
