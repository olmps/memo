import * as assert from "assert";
import { FileSystemGateway } from "#data/gateways/filesystem-gateway";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { LocalCollectionsRepository } from "#data/repositories/local-collections-repository";
import FilesystemError from "#faults/errors/filesystem-error";
import SerializationError from "#faults/errors/serialization-error";
import { LocalPublicCollection } from "#domain/models/collection";
import createSinonStub from "#test/sinon-stub";

describe("LocalCollectionsRepository", () => {
  const fsGatewayStub = createSinonStub(FileSystemGateway);
  const schemaValidatorStub = createSinonStub(SchemaValidator);
  const localCollectionsRepo = new LocalCollectionsRepository(fsGatewayStub, schemaValidatorStub, "any");

  describe("getAllCollectionsByIds", () => {
    it("should return local stored collections", async () => {
      fsGatewayStub.readFileAsString.resolves(JSON.stringify(mockLocalCollectionJson));

      const localCollections = await localCollectionsRepo.getAllCollectionsByIds(["any"]);

      assert.deepStrictEqual(localCollections[0], <LocalPublicCollection>mockLocalCollectionJson);
    });

    it("should throw when reading files from system fails", async () => {
      const mockFsError = new FilesystemError({ message: "Error Message" });

      fsGatewayStub.readFileAsString.rejects(mockFsError);

      assert.rejects(() => localCollectionsRepo.getAllCollectionsByIds([]), FilesystemError);
    });

    it("should throw when collection de-serialization fails", async () => {
      const mockSerializationError = new SerializationError({ message: "Error Message" });

      schemaValidatorStub.validateObject.throws(mockSerializationError);

      assert.rejects(() => localCollectionsRepo.getAllCollectionsByIds([]), SerializationError);
    });
  });
});

const mockLocalCollectionJson = {
  id: "id",
  name: "name",
  description: "Description",
  category: "category",
  tags: ["tag", "tag2"],
  locale: "locale",
  contributors: [],
  resources: [],
  memos: [
    {
      id: "id",
      question: [
        {
          insert: "Question",
        },
      ],
      answer: [
        {
          insert: "Answer",
        },
      ],
    },
  ],
};
