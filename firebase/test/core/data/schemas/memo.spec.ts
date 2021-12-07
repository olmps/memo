import Ajv2020 from "ajv/dist/2020";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { doesNotThrow, throws } from "assert";
import SerializationError from "#faults/errors/serialization-error";
import { SchemaTester, ValidationProperties } from "#testentity-tester";
import { newRawMemo, newRawMemoContent } from "./collections-fakes";

describe("Memo Schema Validation", () => {
  describe("Root Properties - ", () => {
    const properties: ValidationProperties = {
      required: ["id", "question", "answer"],
      array: ["question", "answer"],
      uniqueItems: new Map<string, any[]>([
        ["question", [newRawMemoContent(), newRawMemoContent()]],
        ["answer", [newRawMemoContent(), newRawMemoContent()]],
      ]),
      incorrectTypes: new Map<string, any>([
        ["id", true],
        ["question", "string"],
        ["answer", "string"],
      ]),
    };

    const tester = new SchemaTester({
      schema: "memo",
      entityConstructor: newRawMemo,
      properties: properties,
    });

    tester.runTests();
  });

  describe("Attributes - ", () => {
    const validator = new SchemaValidator(new Ajv2020());
    const allowedAttributesProperties = ["bold", "italic", "underline", "code-block"];

    it("should accept allowed properties", () => {
      const rawMemo = newRawMemo();
      rawMemo.question[0]!.attributes = {};
      rawMemo.answer[0]!.attributes = {};

      for (const property of allowedAttributesProperties) {
        rawMemo.question[0]!.attributes = { ...rawMemo.question[0]!.attributes, [property]: true };
        rawMemo.answer[0]!.attributes = { ...rawMemo.answer[0]!.attributes, [property]: true };

        doesNotThrow(() => validator.validateObject("memo", rawMemo));
      }
    });

    it("should deny not allowed question/answer attribute", () => {
      const rawMemo = newRawMemo();

      rawMemo.question[0]!.attributes = { foo: "bar" };
      rawMemo.answer[0]!.attributes = { foo: "bar" };

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should deny empty question/answer attributes", () => {
      const rawMemo = newRawMemo();

      rawMemo.question[0]!.attributes = {};
      rawMemo.answer[0]!.attributes = {};

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });
  });
});
