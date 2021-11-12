import ValidationError from "@faults/errors/validation-error";
import * as Joi from "joi";

export const defaultMaxStringLength = 255;

/**
 * Validate {@link data} using a `joi` {@link schema}.
 *
 * @param schema The schema to be compared.
 * @param data Object that is matched against schema.
 * @param allowUnknown Allows object to contain unknown keys which are ignored.
 * @param convert Attempts to cast values to the required types.
 */
export function validate(schema: Joi.Schema, data: unknown, allowUnknown = true, convert = false): void {
  const { error } = schema.validate(data, { allowUnknown, convert });

  if (error) {
    const { details } = error;
    const message = details.map((detail) => detail.message).join(",");
    const exception = new ValidationError({ message, origin: error });
    throw exception;
  }
}
