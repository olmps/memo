import Ajv2020 from "ajv/dist/2020";
import * as Joi from "joi";
import { doesNotThrow, throws } from "assert";
import { EntitiesSchema } from "#data/schemas/entities-schemas/entities-schema";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { validate } from "#utils/validate";
import SerializationError from "#faults/errors/serialization-error";
import ValidationError from "#faults/errors/validation-error";

export interface ValidationProperties {
  readonly required: string[];
  readonly optional?: string[];
  readonly string?: string[];
  readonly url?: string[];
  readonly array?: string[];
  /** Maps an array property to a list of repeated items that shouldn't be allowed. */
  readonly uniqueItems?: Map<string, any[]>;
  /**
   * Maps a property to a list of acceptable string values for that property.
   *
   * Useful when validating enums.
   */
  readonly strictValue?: Map<string, string[]>;
  /** Maps a string property to its maximum allowed length. */
  readonly lengthRestricted?: Map<string, number>;
  /** Maps a property to an incorrect type that shouldn't be acceptable. */
  readonly incorrectTypes: Map<string, any>;
}

type ClassConstructor = () => any;
type ValidateFunction = (object: any) => void;

/**
 * Exposes mutual validation functions between entities and schemas.
 *
 * Entities and Schemas share the same validation requirements. The abstract validator exposes such validations that
 * can be extended by both Entity and Schema validators in favor of validations reuse.
 *
 * @see SchemaValidatorBuilder for a Schema specialization.
 * @see EntityValidatorBuilder for an Entity specialization.
 */
abstract class BaseValidator {
  /** Set of properties and its reference values to be validated. */
  readonly #properties: ValidationProperties;
  /** Empty constructor for the entity being validated. */
  readonly #entityConstructor: ClassConstructor;
  /** Validate function used to validate the modified entity. */
  readonly #validator: ValidateFunction;
  /** Expected error type that can be thrown when validating the entity. */
  // eslint-disable-next-line @typescript-eslint/ban-types
  readonly #expectedErrorType: object;

  constructor(props: {
    properties: ValidationProperties;
    entityConstructor: ClassConstructor;
    validator: ValidateFunction;
    // eslint-disable-next-line @typescript-eslint/ban-types
    expectedErrorType: object;
  }) {
    this.#properties = props.properties;
    this.#entityConstructor = props.entityConstructor;
    this.#validator = props.validator;
    this.#expectedErrorType = props.expectedErrorType;
  }

  validate(): void {
    it("should validate raw entity structure", () => {
      const rawEntity = this.#entityConstructor();

      doesNotThrow(() => this.#validator(rawEntity));
    });

    it("should throw when a required property is not set", () => {
      for (const requiredProperty of this.#properties.required) {
        const rawEntity = this.#entityConstructor();

        delete rawEntity[requiredProperty];

        throws(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });

    it("should throw when assigning incorrect type to a property", () => {
      for (const incorrectPropertyEntry of this.#properties.incorrectTypes) {
        const property = incorrectPropertyEntry[0];
        const incorrectType = incorrectPropertyEntry[1];
        const rawEntity = this.#entityConstructor();

        rawEntity[property] = incorrectType;

        throws(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });

    const { optional, string, url, array, uniqueItems, strictValue, lengthRestricted } = this.#properties;

    if (optional !== undefined) {
      this.#valideOptionalProperties(optional);
    }

    if (string !== undefined) {
      this.#validateStringProperties(string);
    }

    if (url !== undefined) {
      this.#validateUrlProperties(url);
    }

    if (array !== undefined) {
      this.#valideArrayProperties(array);
    }

    if (uniqueItems !== undefined) {
      this.#valideUniqueArrayItems(uniqueItems);
    }

    if (strictValue !== undefined) {
      this.#valideStrictValueProperties(strictValue);
    }

    if (lengthRestricted !== undefined) {
      this.#validateLengthRestrictions(lengthRestricted);
    }
  }

  #valideOptionalProperties(properties: string[]): void {
    it("should not throw when a optional property is not set", () => {
      for (const optionalProperty of properties) {
        const rawEntity = this.#entityConstructor();

        delete rawEntity[optionalProperty];

        doesNotThrow(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });
  }

  #validateStringProperties(properties: string[]): void {
    it("should throw when a string property is empty", () => {
      for (const stringProperty of properties) {
        const rawEntity = this.#entityConstructor();

        rawEntity[stringProperty] = "";

        throws(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });
  }

  #validateUrlProperties(properties: string[]): void {
    it("should throw when an url property doesn't have valid format", () => {
      for (const urlProperty of properties) {
        const rawEntity = this.#entityConstructor();

        rawEntity[urlProperty] = "invalidUrlFormat";

        throws(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });
  }

  #valideArrayProperties(properties: string[]): void {
    it("should throw when a required array is empty", () => {
      for (const arrayProperty of properties) {
        const rawEntity = this.#entityConstructor();

        rawEntity[arrayProperty] = [];

        throws(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });
  }

  #valideUniqueArrayItems(properties: Map<string, any[]>): void {
    it("should throw when array has repeated items", () => {
      for (const repeatedProperty of properties) {
        const property = repeatedProperty[0];
        const repeatedItems = repeatedProperty[1];
        const rawEntity = this.#entityConstructor();

        rawEntity[property] = repeatedItems;

        throws(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });
  }

  #valideStrictValueProperties(properties: Map<string, string[]>): void {
    it("should accept allowed strict values", () => {
      for (const strictProperty of properties) {
        const property = strictProperty[0];
        const allowedValues = strictProperty[1];

        for (const value of allowedValues) {
          const rawEntity = this.#entityConstructor();

          rawEntity[property] = value;

          doesNotThrow(() => this.#validator(rawEntity));
        }
      }
    });

    it("should throw when using unexpected strict value", () => {
      for (const strictProperty of properties.keys()) {
        const rawEntity = this.#entityConstructor();

        rawEntity[strictProperty] = "unexpectedType";

        throws(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });
  }

  #validateLengthRestrictions(properties: Map<string, number>): void {
    it("should throw when string property length is greater than max allowed", () => {
      for (const restrictedProperty of properties) {
        const property = restrictedProperty[0];
        const propertyMaxLength = restrictedProperty[1];
        const rawEntity = this.#entityConstructor();

        rawEntity[property] = "a".repeat(propertyMaxLength + 1);

        throws(() => this.#validator(rawEntity), this.#expectedErrorType);
      }
    });
  }
}

/** A {@link BaseValidator} specialization for Schema validations. */
export class SchemaValidatorBuilder extends BaseValidator {
  constructor(props: {
    schema: EntitiesSchema;
    properties: ValidationProperties;
    entityConstructor: ClassConstructor;
  }) {
    const validator = new SchemaValidator(new Ajv2020());
    const validateFunction = (object: any) => validator.validateObject(props.schema, object);
    super({
      properties: props.properties,
      entityConstructor: props.entityConstructor,
      validator: validateFunction,
      expectedErrorType: SerializationError,
    });
  }
}

/** A {@link BaseValidator} specialization for Entity validations. */
export class EntityValidatorBuilder extends BaseValidator {
  constructor(props: { schema: Joi.Schema; properties: ValidationProperties; entityConstructor: ClassConstructor }) {
    const validateFunction = (object: any) => validate(props.schema, object);
    super({
      properties: props.properties,
      entityConstructor: props.entityConstructor,
      validator: validateFunction,
      expectedErrorType: ValidationError,
    });
  }
}
