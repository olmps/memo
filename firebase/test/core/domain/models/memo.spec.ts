import ValidationError from "#faults/errors/validation-error";
import { Memo, memoContentValidationSchema, memoValidationSchema } from "#domain/models/memo";
import { throws } from "assert";
import { defaultMaxStringLength, validate } from "#utils/validate";

describe("Memo Content Validation", () => {
  describe("Base Properties", () => {
    describe("Id - ", () => {
      it("should throw when id is not set", () => {
        const fakeMemo = {
          question: [{ insert: "any" }],
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when id is empty", () => {
        const fakeMemo: Memo = {
          uniqueId: "",
          question: [{ insert: "any" }],
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when id is greater than max allowed string length", () => {
        const fakeId = "a".repeat(defaultMaxStringLength + 1);
        const fakeMemo: Memo = {
          uniqueId: fakeId,
          question: [{ insert: "any" }],
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when id is not a string", () => {
        const fakeMemo = {
          uniqueId: true,
          question: [{ insert: "any" }],
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });
    });

    describe("Question - ", () => {
      it("should throw when question is not set", () => {
        const fakeMemo = {
          uniqueId: "any",
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when question is empty", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [],
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when question is not an array", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: true,
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });
    });

    describe("Answer - ", () => {
      it("should throw when answer is not set", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when answer is empty", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "any" }],
          answer: [],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when answer is not an array", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "any" }],
          answer: true,
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });
    });
  });

  describe("Content Properties - ", () => {
    describe("Question - ", () => {
      it("should throw when insert is not set", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [{}],
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when insert is empty", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "" }],
          answer: [{ insert: "any" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });
    });

    describe("Answer - ", () => {
      it("should throw when insert is not set", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "any" }],
          answer: [{}],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when insert is empty", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "any" }],
          answer: [{ insert: "" }],
        };

        throws(() => validate(memoValidationSchema, fakeMemo), ValidationError);
      });
    });

    describe("Attributes - ", () => {
      it("should throw when attributes is empty", () => {
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "any", attributes: {} }],
          answer: [{ insert: "any", attributes: {} }],
        };

        throws(() => validate(memoContentValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when attributes has invalid property", () => {
        const fakeAttributes = {
          foo: "bar",
        };
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "any", attributes: fakeAttributes }],
          answer: [{ insert: "any", attributes: fakeAttributes }],
        };

        throws(() => validate(memoContentValidationSchema, fakeMemo), ValidationError);
      });

      it("should throw when attributes has invalid type", () => {
        const fakeAttributes = {
          bold: "bar",
          italic: "bar",
          underscore: "bar",
          codeBlock: "bar",
        };
        const fakeMemo = {
          uniqueId: "any",
          question: [{ insert: "any", attributes: fakeAttributes }],
          answer: [{ insert: "any", attributes: fakeAttributes }],
        };

        throws(() => validate(memoContentValidationSchema, fakeMemo), ValidationError);
      });
    });
  });
});
