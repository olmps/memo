/* eslint-disable @typescript-eslint/no-var-requires */
import Ajv2020 from "ajv/dist/2020";
import { JSONSchemaType } from "ajv";
import { AnyValidateFunction } from "ajv/dist/types";
import { EntitiesSchema } from "./entities-schemas/entities-schema";
import SerializationError from "@faults/errors/serialization-error";

/** Available schemas types to be matched in {@link SchemaValidator.validateObject} */
export type SchemaType = EntitiesSchema;

/** Match predefined {@link SchemaType} to validate raw objects. */
export class SchemaValidator {
  readonly #ajv;
  readonly #entitiesSchemasRoot = "./entities-schemas";

  constructor(ajv: Ajv2020) {
    this.#ajv = ajv;
    // TODO(matuella): Find a way to load dependant schemas on demand, just like others are being loaded.
    // The below schemas are a dependancy from others (a "$ref").
    const loadedSchema = require(`${this.#entitiesSchemasRoot}/public-collection.json`);
    this.#ajv.addSchema(loadedSchema, "public-collection");

    const memoLoadedSchema = require(`${this.#entitiesSchemasRoot}/memo.json`);
    this.#ajv.addSchema(memoLoadedSchema, "memo");
  }

  /**
   * Checks if {@link data} has all the required properties, defined in {@link schema}.
   *
   * @param schema Schema to compare {@link data}.
   * @param data Raw object.
   *
   * @throws {SerializationError} if {@link data} doesn't conform to the {@link schema}.
   */
  validateObject(schema: SchemaType, data: Record<string, unknown>): void {
    const validate = this.#getValidateForSchema(schema);

    if (!validate(data)) {
      throw new SerializationError({
        message: `Failed to serialize schema ${validate.schema} with ${validate.errors?.length} errors.`,
        origin: validate.errors,
      });
    }
  }

  /** Retrieves the `ajv` {@link schema} in a lazy fashion. Caches all subsequent calls to the same {@link schema}. */
  #getValidateForSchema(schema: SchemaType): AnyValidateFunction<JSONSchemaType<unknown>> {
    const validateSchema = this.#ajv.getSchema(schema);

    if (!validateSchema) {
      const loadedSchema = require(`./entities-schemas/${schema}.json`);
      this.#ajv.addSchema(loadedSchema, schema);
    }

    return this.#ajv.getSchema(schema)!;
  }
}
