import { defaultMaxStringLength, validate } from "#utils/validate";
import * as Joi from "joi";

export interface Memo {
  readonly id: string;
  readonly question: Record<string, unknown>[];
  readonly answer: Record<string, unknown>[];
}

export const memoValidationSchema = Joi.object({
  id: Joi.string().max(defaultMaxStringLength).required(),
  question: Joi.array().items(Joi.object()).min(1).required(),
  answer: Joi.array().items(Joi.object()).min(1).required(),
});

export function validateMemo(memo: Memo): void {
  validate(memoValidationSchema, memo);
}
