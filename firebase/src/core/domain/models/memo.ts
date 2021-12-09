import { defaultMaxStringLength, validate } from "#utils/validate";
import * as Joi from "joi";

interface Attributes {
  bold?: boolean;
  italic?: boolean;
  underline?: boolean;
}

interface MemoAttributes extends Attributes {
  codeBlock?: boolean;
}

// Local stored memos use kebab-case in its attributes instead camel-case.
interface LocalMemoAttributes extends Attributes {
  "code-block"?: boolean;
}

interface MemoContent<T extends Attributes> {
  insert: string;
  attributes?: T;
}

export interface Memo {
  readonly id: string;
  readonly question: MemoContent<MemoAttributes>[];
  readonly answer: MemoContent<MemoAttributes>[];
}

export interface LocalMemo {
  readonly id: string;
  readonly question: MemoContent<LocalMemoAttributes>[];
  readonly answer: MemoContent<LocalMemoAttributes>[];
}

const attributeValidation = Joi.object({
  bold: Joi.boolean(),
  italic: Joi.boolean(),
  underline: Joi.boolean(),
}).min(1);

export const memoQuillValidationSchema = Joi.object({
  insert: Joi.string().required(),
  attributes: attributeValidation.append({
    codeBlock: Joi.boolean(),
  }),
});

export const memoValidationSchema = Joi.object({
  id: Joi.string().max(defaultMaxStringLength).required(),
  question: Joi.array().items(memoQuillValidationSchema).min(1).required(),
  answer: Joi.array().items(memoQuillValidationSchema).min(1).required(),
});

export function validateMemo(memo: Memo): void {
  validate(memoValidationSchema, memo);
}

export const localMemoQuillValidationSchema = Joi.object({
  insert: Joi.string().required(),
  attributes: attributeValidation.append({
    "code-block": Joi.boolean(),
  }),
});

export const localMemoValidationSchema = Joi.object({
  id: Joi.string().max(defaultMaxStringLength).required(),
  question: Joi.array().items(localMemoQuillValidationSchema).min(1).required(),
  answer: Joi.array().items(localMemoQuillValidationSchema).min(1).required(),
});

export function validateLocalMemo(localMemo: LocalMemo): void {
  validate(localMemoValidationSchema, localMemo);
}
