import * as assert from "assert";
import * as sinon from "sinon";
import { SchemaValidator } from "#data/schemas/schema-validator";
import SerializationError from "#faults/errors/serialization-error";
import { StoredPublicCollection } from "#domain/models/collection";
import { StoredCollectionsRepository } from "#data/repositories/stored-collections-repository";
import { FirestoreGateway } from "#data/gateways/firestore-gateway";

describe("StoredCollectionsRepository", () => {
  let sandbox: sinon.SinonSandbox;
  let firestoreGateway: sinon.SinonStubbedInstance<FirestoreGateway>;
  let schemaValidator: sinon.SinonStubbedInstance<SchemaValidator>;
  let storedCollectionsRepo: StoredCollectionsRepository;

  beforeEach(() => {
    sandbox = sinon.createSandbox();
    firestoreGateway = sandbox.createStubInstance(FirestoreGateway);
    // Mocks the transaction function to always run what's is inside the context
    firestoreGateway.runTransaction.callsFake(async (context) => {
      await context();
    });
    schemaValidator = sandbox.createStubInstance(SchemaValidator);
    storedCollectionsRepo = new StoredCollectionsRepository(
      <FirestoreGateway>(<any>firestoreGateway),
      <SchemaValidator>(<any>schemaValidator)
    );
  });

  afterEach(() => {
    sandbox.restore();
  });

  describe("setCollections", () => {
    it("should update Collections set inside a single transaction", async () => {
      const mockCollection = _newCollection();

      await storedCollectionsRepo.setCollections([mockCollection]);

      assert.ok(firestoreGateway.runTransaction.calledOnce);
    });

    it("should throw when one of the Collections has invalid format", () => {
      const malformedCollection: StoredPublicCollection = <any>{ id: "id2", foo: "bar" };
      const mockCollections = [_newCollection(), malformedCollection];

      assert.rejects(() => storedCollectionsRepo.setCollections(mockCollections), SerializationError);
    });

    it("should update Collections using their raw representation", async () => {
      const mockCollection = _newCollection();
      const expectedId = mockCollection.id;
      const expectedPath = "collections";
      const expectedData = <any>mockCollection;

      await storedCollectionsRepo.setCollections([mockCollection]);
      const { id, path, data } = firestoreGateway.setDoc.lastCall.firstArg;

      assert.strictEqual(id, expectedId);
      assert.strictEqual(path, expectedPath);
      assert.strictEqual(data, expectedData);
    });
  });

  describe("deleteCollectionsByIds", () => {
    it("should remove Collections set from a collection inside a single transaction", async () => {
      await storedCollectionsRepo.deleteCollectionsByIds(["any"]);

      assert.ok(firestoreGateway.runTransaction.calledOnce);
    });

    it("should remove a Collection by its id", async () => {
      const expectedId = "anyId";
      const expectedPath = "collections";

      await storedCollectionsRepo.deleteCollectionsByIds([expectedId]);
      const { id, path } = firestoreGateway.deleteDocRecursively.lastCall.firstArg;

      assert.strictEqual(id, expectedId);
      assert.strictEqual(path, expectedPath);
    });
  });

  describe("getAllCollectionsByIds", async () => {
    it("should return deserialized Collections", async () => {
      const firstRawCollection = _newCollection({ id: "id1" });
      const secondRawCollection = _newCollection({ id: "id2" });

      firestoreGateway.getDoc.withArgs({ id: firstRawCollection.id, path: "collections" }).resolves(firstRawCollection);
      firestoreGateway.getDoc
        .withArgs({ id: secondRawCollection.id, path: "collections" })
        .resolves(secondRawCollection);
      const collections = await storedCollectionsRepo.getAllCollectionsByIds([
        firstRawCollection.id,
        secondRawCollection.id,
      ]);

      assert.strictEqual(collections.length, 2);
      assert.strictEqual(collections[0]!.id, firstRawCollection.id);
      assert.strictEqual(collections[1]!.id, secondRawCollection.id);
    });

    it("should throw when a Collection is not in the expected schema format", () => {
      const firstRawCollection = _newCollection({ id: "id1" });
      const secondRawCollection = { id: "2", foo: "bar" };

      firestoreGateway.getDoc.withArgs({ id: firstRawCollection.id, path: "collections" }).resolves(firstRawCollection);
      firestoreGateway.getDoc
        .withArgs({ id: secondRawCollection.id, path: "collections" })
        .resolves(secondRawCollection);

      assert.rejects(
        () => storedCollectionsRepo.getAllCollectionsByIds([firstRawCollection.id, secondRawCollection.id]),
        SerializationError
      );
    });
  });
});

function _newCollection(props?: { id?: string }): StoredPublicCollection {
  return {
    id: props?.id ?? "any",
    name: "Collection name",
    contributors: [],
    resources: [],
    memosAmount: 1,
    memosOrder: ["memo1", "memo2", "memo3"],
  };
}
