import Ajv2020 from "ajv/dist/2020";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { doesNotThrow, throws } from "assert";
import SerializationError from "#faults/errors/serialization-error";

describe("Memo Schema Validation", () => {
  const validator = new SchemaValidator(new Ajv2020());
  const allowedProperties = ["bold", "italic", "underline", "code-block"];
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let rawMemo: any;

  beforeEach(() => {
    rawMemo = {
      uniqueId: "any",
      question: [
        {
          insert: "Question string",
        },
      ],
      answer: [
        {
          insert: "Answer string",
        },
      ],
    };
  });

  it("should validate raw memo structure", () => {
    doesNotThrow(() => validator.validateObject("memo", rawMemo));
  });

  it("should throw when question id is not present", () => {
    delete rawMemo.uniqueId;

    throws(() => validator.validateObject("memo", rawMemo), SerializationError);
  });

  describe("Question - ", () => {
    it("should throw when question is not present", () => {
      delete rawMemo.question;

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should throw when question content is not present", () => {
      delete rawMemo.question[0].insert;

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should throw when question is empty", () => {
      rawMemo.question = [];

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should throw when question has incorrect type", () => {
      rawMemo.question = true;

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });
  });

  describe("Answer - ", () => {
    it("should throw when answer is not present", () => {
      delete rawMemo.answer;

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should throw when answer content is not present", () => {
      delete rawMemo.answer[0].insert;

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should throw when answer is empty", () => {
      delete rawMemo.answer;

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should throw when answer has incorrect type", () => {
      rawMemo.answer = true;

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });
  });

  describe("Attributes - ", () => {
    it("should accept allowed properties", () => {
      rawMemo.question[0]!.attributes = {};
      rawMemo.answer[0]!.attributes = {};

      for (const property of allowedProperties) {
        rawMemo.question[0]!.attributes = { ...rawMemo.question[0]!.attributes, [property]: true };
        rawMemo.answer[0]!.attributes = { ...rawMemo.answer[0]!.attributes, [property]: true };

        doesNotThrow(() => validator.validateObject("memo", rawMemo));
      }
    });

    it("should deny not allowed question attribute", () => {
      rawMemo.question[0]!.attributes = { foo: "bar" };

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should deny not allowed answer attribute", () => {
      rawMemo.answer[0]!.attributes = { foo: "bar" };

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should deny empty question attributes", () => {
      rawMemo.question[0]!.attributes = {};

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });

    it("should deny empty answer attributes", () => {
      rawMemo.question[0]!.attributes = {};

      throws(() => validator.validateObject("memo", rawMemo), SerializationError);
    });
  });
});
