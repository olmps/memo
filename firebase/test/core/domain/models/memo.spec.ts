import ValidationError from "#faults/errors/validation-error";
import { memoQuillValidationSchema, memoValidationSchema } from "#domain/models/memo";
import { throws } from "assert";
import { defaultMaxStringLength, validate } from "#utils/validate";
import { ModelTester, ValidationProperties } from "#testentity-tester";
import { newRawMemo, newRawMemoContent } from "#test/core/data/schemas/collections-fakes";

describe("Memo Content Validation", () => {
  describe("Root Properties", () => {
    const properties: ValidationProperties = {
      required: ["id", "question", "answer"],
      array: ["question", "answer"],
      incorrectTypes: new Map<string, any>([
        ["id", true],
        ["question", "string"],
        ["answer", "string"],
      ]),
      lengthRestricted: new Map<string, any>([["id", defaultMaxStringLength]]),
    };

    const tester = new ModelTester({
      schema: memoValidationSchema,
      entityConstructor: newRawMemo,
      properties: properties,
    });

    tester.runTests();
  });

  describe("Content Properties - ", () => {
    const properties: ValidationProperties = {
      required: ["insert"],
      optional: ["attributes"],
      incorrectTypes: new Map<string, any>([
        ["insert", 0],
        ["attributes", "string"],
      ]),
    };

    const tester = new ModelTester({
      schema: memoQuillValidationSchema,
      entityConstructor: newRawMemoContent,
      properties: properties,
    });

    tester.runTests();

    describe("Attributes - ", () => {
      it("should throw when attributes is empty", () => {
        const fakeMemo = {
          id: "any",
          question: [{ insert: "any", attributes: {} }],
          answer: [{ insert: "any", attributes: {} }],
        };

        throws(() => validate(memoQuillValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when attributes has invalid property", () => {
        const fakeAttributes = {
          foo: "bar",
        };
        const fakeMemo = {
          id: "any",
          question: [{ insert: "any", attributes: fakeAttributes }],
          answer: [{ insert: "any", attributes: fakeAttributes }],
        };

        throws(() => validate(memoQuillValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when attributes has invalid type", () => {
        const fakeAttributes = {
          bold: "bar",
          italic: "bar",
          underscore: "bar",
          codeBlock: "bar",
        };
        const fakeMemo = {
          id: "any",
          question: [{ insert: "any", attributes: fakeAttributes }],
          answer: [{ insert: "any", attributes: fakeAttributes }],
        };

        throws(() => validate(memoQuillValidationSchema, fakeMemo), ValidationError);
      });
    });
  });
});
