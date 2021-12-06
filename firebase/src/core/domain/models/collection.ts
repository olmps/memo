import { Memo, memoValidationSchema } from "#domain/models/memo";
import { defaultMaxStringLength, validate } from "#utils/validate";
import * as Joi from "joi";

interface Collection {
  readonly id: string;
  readonly name: string;
  readonly description: string;
  readonly tags: string[];
  readonly category: string;

  readonly locale?: string;
}

interface PublicCollection extends Collection {
  readonly contributors: CollectionContributor[];
  readonly resources: CollectionResource[];
}

interface CollectionContributor {
  readonly name: string;
  readonly url: string;
  readonly avatarUrl: string;
}

export enum CollectionResourceType {
  article = "article",
  book = "book",
  video = "video",
  other = "other",
}

interface CollectionResource {
  readonly type: CollectionResourceType;
  readonly description: string;
  readonly url: string;
}

export interface LocalPublicCollection extends PublicCollection {
  readonly memos: Memo[];
}

export interface StoredPublicCollection extends PublicCollection {
  /** Aggregate property that specifies that amount of memos associated with this collection. */
  readonly memosAmount: number;

  /** Aggregate property that specifies that order of memos (by their ids) associated with this collection. */
  readonly memosOrder: string[];
}

const publicCollectionSchema = Joi.object({
  id: Joi.string().max(defaultMaxStringLength).required(),
  name: Joi.string().max(defaultMaxStringLength).required(),
  tags: Joi.array().items(Joi.string()).min(1).required(),
  category: Joi.string().max(defaultMaxStringLength).required(),
  description: Joi.string().max(10000).required(),
  locale: Joi.string().max(defaultMaxStringLength).required(),
  contributors: Joi.array()
    .items(
      Joi.object({
        name: Joi.string().max(defaultMaxStringLength).required(),
        url: Joi.string().uri().required(),
        avatarUrl: Joi.string().uri().required(),
      })
    )
    .min(1)
    .required(),
  resources: Joi.array()
    .items(
      Joi.object({
        type: Joi.valid(...Object.values(CollectionResourceType)).required(),
        url: Joi.string().uri().required(),
        description: Joi.string().max(defaultMaxStringLength).required(),
      })
    )
    .min(1)
    .required(),
});

const localCollectionSchema = publicCollectionSchema.append({
  memos: Joi.array().items(memoValidationSchema).min(1).required(),
});

const storedCollectionSchema = publicCollectionSchema.append({
  memosAmount: Joi.number().integer().min(1).required(),
  memosOrder: Joi.array().items(Joi.string()).min(1).required(),
});
// TODO: How to compare between same-object properties?
// .assert(Joi.ref("memosAmount"), Joi.ref("memosOrder.length"));

export function validateLocalCollection(collection: LocalPublicCollection): void {
  validate(localCollectionSchema, collection);
}

export function validateStoredCollection(collection: StoredPublicCollection): void {
  validate(storedCollectionSchema, collection);
}
