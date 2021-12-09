import { defaultMaxStringLength, validate } from "#utils/validate";
import * as Joi from "joi";

interface MemoContent {
  insert: string;
  attributes?: {
    bold?: boolean;
    italic?: boolean;
    underline?: boolean;
    // Quill uses `kebab-case` format for attributes
    "code-block"?: boolean;
  };
}

export interface Memo {
  readonly id: string;
  readonly question: MemoContent[];
  readonly answer: MemoContent[];
}

const maxInsertLength = 3000;
export const memoQuillValidationSchema = Joi.object({
  insert: Joi.string().max(maxInsertLength).required(),
  attributes: Joi.object({
    bold: Joi.boolean(),
    italic: Joi.boolean(),
    underline: Joi.boolean(),
    "code-block": Joi.boolean(),
  }).min(1),
});

export const memoValidationSchema = Joi.object({
  id: Joi.string().max(defaultMaxStringLength).required(),
  question: Joi.array().items(memoQuillValidationSchema).min(1).required(),
  answer: Joi.array().items(memoQuillValidationSchema).min(1).required(),
});

export function validateMemo(memo: Memo): void {
  validate(memoValidationSchema, memo);
}
