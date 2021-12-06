import * as Joi from "joi";
import * as assert from "assert";
import { validate } from "#utils/validate";
import ValidationError from "#faults/errors/validation-error";

describe("validate", () => {
  const maxLength = 10;
  const objectSchema = Joi.object({
    property: Joi.string().max(maxLength).required(),
  });
  const value = "a".repeat(maxLength + 1);
  const object = { property: value };

  it("should throw a ValidationError when validation fails", () => {
    assert.throws(() => validate(objectSchema, object), ValidationError);
  });

  it("should add validation error details to ValidationError", () => {
    const { error } = objectSchema.validate(object);
    const errorDetails = error!.details.map((detail) => detail.message).join(",");
    const expectedValidationError = new ValidationError({ message: errorDetails, origin: error });

    assert.throws(() => validate(objectSchema, object), expectedValidationError);
  });
});
