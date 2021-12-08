import {
  publicCollectionSchema,
  maxDescriptionLength,
  CollectionResourceType,
  collectionContributorSchema,
  collectionResourcesSchema,
} from "#domain/models/collection";
import { defaultMaxStringLength } from "#utils/validate";
import { newRawContributor, newRawLocalCollection, newRawResource } from "#test/core/data/schemas/collections-fakes";
import { ValidationProperties, ModelTester } from "#test/entity-tester";

describe("PublicCollection Validation", () => {
  describe("Root Properties - ", () => {
    const properties: ValidationProperties = {
      required: ["id", "name", "description", "tags", "category", "contributors", "resources"],
      optional: ["locale"],
      array: ["tags", "contributors", "resources"],
      string: ["id", "name", "description", "category"],
      uniqueItems: new Map<string, unknown[]>([
        ["tags", ["Tag", "Tag"]],
        ["contributors", [newRawContributor(), newRawContributor()]],
        ["resources", [newRawResource(), newRawResource()]],
      ]),
      incorrectTypes: new Map<string, unknown>([
        ["id", true],
        ["name", true],
        ["description", true],
        ["tags", "string"],
        ["category", true],
        ["contributors", "string"],
        ["resources", "string"],
        ["locale", 0],
      ]),
      lengthRestricted: new Map<string, number>([
        ["id", defaultMaxStringLength],
        ["name", defaultMaxStringLength],
        ["description", maxDescriptionLength],
        ["category", defaultMaxStringLength],
      ]),
    };

    const tester = new ModelTester({
      schema: publicCollectionSchema,
      entityConstructor: newRawLocalCollection,
      properties: properties,
    });

    tester.runTests();
  });

  describe("Contributors - ", () => {
    const properties: ValidationProperties = {
      required: ["name", "url", "avatarUrl"],
      string: ["name", "url", "avatarUrl"],
      url: ["url", "avatarUrl"],
      incorrectTypes: new Map<string, unknown>([
        ["name", true],
        ["url", true],
        ["avatarUrl", true],
      ]),
      lengthRestricted: new Map<string, number>([["name", defaultMaxStringLength]]),
    };

    const tester = new ModelTester({
      schema: collectionContributorSchema,
      entityConstructor: newRawContributor,
      properties: properties,
    });

    tester.runTests();
  });

  describe("Resources - ", () => {
    const properties: ValidationProperties = {
      required: ["description", "type", "url"],
      string: ["description", "type", "url"],
      url: ["url"],
      incorrectTypes: new Map<string, unknown>([
        ["description", true],
        ["type", 0],
        ["url", true],
      ]),
      lengthRestricted: new Map<string, number>([["description", maxDescriptionLength]]),
      strictValue: new Map<string, string[]>([["type", Object.values(CollectionResourceType)]]),
    };

    const tester = new ModelTester({
      schema: collectionResourcesSchema,
      entityConstructor: newRawResource,
      properties: properties,
    });

    tester.runTests();
  });
});
