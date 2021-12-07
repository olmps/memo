import { newRawContributor, newRawPublicCollection, newRawResource } from "./collections-fakes";
import { SchemaValidatorBuilder, ValidationProperties } from "#test/validator";
import { CollectionResourceType } from "#domain/models/collection";

describe("Public Collection Schema Validation", () => {
  describe("Root Properties - ", () => {
    const properties: ValidationProperties = {
      required: ["id", "name", "description", "tags", "category", "contributors", "resources"],
      optional: ["locale"],
      array: ["tags", "contributors", "resources"],
      string: ["id", "name", "description", "category"],
      uniqueItems: new Map<string, any[]>([
        ["tags", ["Tag", "Tag"]],
        ["contributors", [newRawContributor(), newRawContributor()]],
        ["resources", [newRawResource(), newRawResource()]],
      ]),
      incorrectTypes: new Map<string, any>([
        ["id", true],
        ["name", true],
        ["description", true],
        ["tags", "string"],
        ["category", true],
        ["contributors", "string"],
        ["resources", "string"],
        ["locale", 0],
      ]),
    };
    const validator = new SchemaValidatorBuilder({
      schema: "public-collection",
      entityConstructor: newRawPublicCollection,
      properties: properties,
    });

    validator.validate();
  });

  describe("Contributors - ", () => {
    const properties: ValidationProperties = {
      required: ["name", "url", "avatarUrl"],
      string: ["name", "url", "avatarUrl"],
      url: ["url", "avatarUrl"],
      incorrectTypes: new Map<string, any>([
        ["name", true],
        ["url", true],
        ["avatarUrl", true],
      ]),
    };

    const validator = new SchemaValidatorBuilder({
      schema: "collection-contributors",
      entityConstructor: newRawContributor,
      properties: properties,
    });

    validator.validate();
  });

  describe("Resources - ", () => {
    const properties: ValidationProperties = {
      required: ["description", "type", "url"],
      string: ["description", "type", "url"],
      url: ["url"],
      incorrectTypes: new Map<string, any>([
        ["description", true],
        ["type", 0],
        ["url", true],
      ]),
      strictValue: new Map<string, string[]>([["type", Object.values(CollectionResourceType)]]),
    };

    const validator = new SchemaValidatorBuilder({
      schema: "collection-resources",
      entityConstructor: newRawResource,
      properties: properties,
    });

    validator.validate();
  });
});
