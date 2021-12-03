import * as assert from "assert";
import * as sinon from "sinon";
import { FileSystemGateway } from "#data/gateways/filesystem-gateway";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { LocalCollectionsRepository } from "#data/repositories/local-collections-repository";
import FilesystemError from "#faults/errors/filesystem-error";
import SerializationError from "#faults/errors/serialization-error";
import { LocalPublicCollection } from "#domain/models/collection";

describe("LocalCollectionsRepository", () => {
  const fsGateway = sinon.createStubInstance(FileSystemGateway);
  const schemaValidator = sinon.createStubInstance(SchemaValidator);
  const localCollectionsRepo = new LocalCollectionsRepository(
    <FileSystemGateway>(<any>fsGateway),
    <SchemaValidator>(<any>schemaValidator),
    "any"
  );

  describe("getAllCollectionsByIds", () => {
    it("should return local stored collections", async () => {
      fsGateway.readFileAsString.resolves(JSON.stringify(mockLocalCollectionJson));

      const localCollections = await localCollectionsRepo.getAllCollectionsByIds(["any"]);

      assert.deepStrictEqual(localCollections[0], <LocalPublicCollection>mockLocalCollectionJson);
    });

    it("should fail to retrieve collections when file system read fails", async () => {
      const fsError = new FilesystemError({ message: "Error Message" });

      fsGateway.readFileAsString.rejects(fsError);

      assert.rejects(() => localCollectionsRepo.getAllCollectionsByIds([]), fsError);
    });

    it("should fail to retrieve collections when de-serialization fails", async () => {
      const serializationError = new SerializationError({ message: "Error Message" });

      schemaValidator.validateObject.throws(serializationError);

      assert.rejects(() => localCollectionsRepo.getAllCollectionsByIds([]), serializationError);
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
