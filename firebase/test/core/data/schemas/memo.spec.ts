import Ajv2020 from "ajv/dist/2020";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { doesNotThrow, throws } from "assert";
import SerializationError from "#faults/errors/serialization-error";

describe("Memo Schema Validation", () => {
  const validator = new SchemaValidator(new Ajv2020());
  const requiredProperties = ["id", "question", "answer"];
  const arrayProperties = ["question", "answer"];
  // Maps a property to a type that couldn't be associated to it.
  const incorrectPropertiesTypes = new Map<string, any>([
    ["id", true],
    ["question", "string"],
    ["answer", "string"],
  ]);
  const allowedAttributesProperties = ["bold", "italic", "underline", "code-block"];

  it("should validate raw memo structure", () => {
    const rawMemo = _newRawMemo();

    doesNotThrow(() => validator.validateObject("memo", rawMemo));
  });

  it("should throw when a required property is not set", () => {
    for (const requiredProperty of requiredProperties) {
      const rawMemo = _newRawMemo();

      delete rawMemo[requiredProperty];

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    }
  });

  it("should thrown when a required array is empty", () => {
    for (const arrayProperty of arrayProperties) {
      const rawMemo = _newRawMemo();

      rawMemo[arrayProperty] = [];

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    }
  });

  it("should thrown when assigning incorrect type to a property", () => {
    for (const incorrectPropertyEntry of incorrectPropertiesTypes) {
      const property = incorrectPropertyEntry[0];
      const incorrectType = incorrectPropertyEntry[1];
      const rawMemo = _newRawMemo();

      rawMemo[property] = incorrectType;

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    }
  });

  it("should throw when question/answer content is not present", () => {
    const rawMemo = _newRawMemo();

    delete rawMemo.question[0].insert;
    delete rawMemo.answer[0].insert;

    throws(() => validator.validateObject("memo", rawMemo), SerializationError);
  });

  describe("Attributes - ", () => {
    it("should accept allowed properties", () => {
      const rawMemo = _newRawMemo();
      rawMemo.question[0]!.attributes = {};
      rawMemo.answer[0]!.attributes = {};

      for (const property of allowedAttributesProperties) {
        rawMemo.question[0]!.attributes = { ...rawMemo.question[0]!.attributes, [property]: true };
        rawMemo.answer[0]!.attributes = { ...rawMemo.answer[0]!.attributes, [property]: true };

        doesNotThrow(() => validator.validateObject("memo", rawMemo));
      }
    });

    it("should deny not allowed question/answer attribute", () => {
      const rawMemo = _newRawMemo();

      rawMemo.question[0]!.attributes = { foo: "bar" };
      rawMemo.answer[0]!.attributes = { foo: "bar" };

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should deny empty question/answer attributes", () => {
      const rawMemo = _newRawMemo();

      rawMemo.question[0]!.attributes = {};
      rawMemo.answer[0]!.attributes = {};

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });
  });
});

function _newRawMemo(): any {
  return {
    id: "any",
    question: [_newRawMemoContent()],
    answer: [_newRawMemoContent()],
  };
}

function _newRawMemoContent(): any {
  return {
    insert: "Content string",
  };
}
