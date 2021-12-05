import * as assert from "assert";
import * as sinon from "sinon";
import { FileSystemGateway } from "#data/gateways/filesystem-gateway";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { LocalCollectionsRepository } from "#data/repositories/local-collections-repository";
import FilesystemError from "#faults/errors/filesystem-error";
import SerializationError from "#faults/errors/serialization-error";
import { LocalPublicCollection } from "#domain/models/collection";
import createSinonStub from "#test/sinon-stub";

describe("LocalCollectionsRepository", () => {
  let sandbox: sinon.SinonSandbox;
  let fsGatewayStub: sinon.SinonStubbedInstance<FileSystemGateway>;
  let schemaValidatorStub: sinon.SinonStubbedInstance<SchemaValidator>;
  let localCollectionsRepo: LocalCollectionsRepository;

  beforeEach(() => {
    sandbox = sinon.createSandbox();

    const fsStub = createSinonStub(FileSystemGateway);
    fsGatewayStub = fsStub;

    const schemaStub = createSinonStub(SchemaValidator);
    schemaValidatorStub = schemaStub;

    localCollectionsRepo = new LocalCollectionsRepository(fsStub, schemaStub, "any");
  });

  afterEach(() => {
    sandbox.restore();
  });

  describe("getAllCollectionsByIds", () => {
    it("should return local stored collections", async () => {
      fsGatewayStub.readFileAsString.resolves(JSON.stringify(fakeLocalCollectionJson));

      const localCollections = await localCollectionsRepo.getAllCollectionsByIds(["any"]);

      assert.deepStrictEqual(localCollections[0], <LocalPublicCollection>fakeLocalCollectionJson);
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

const fakeLocalCollectionJson = {
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
