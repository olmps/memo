import * as assert from "assert";
import * as sinon from "sinon";
import { SchemaValidator } from "#data/schemas/schema-validator";
import SerializationError from "#faults/errors/serialization-error";
import { StoredPublicCollection } from "#domain/models/collection";
import { StoredCollectionsRepository } from "#data/repositories/stored-collections-repository";
import { FirestoreGateway } from "#data/gateways/firestore-gateway";
import createSinonStub from "#test/sinon-stub";

describe("StoredCollectionsRepository", () => {
  let sandbox: sinon.SinonSandbox;
  let firestoreStub: sinon.SinonStubbedInstance<FirestoreGateway>;
  let storedCollectionsRepo: StoredCollectionsRepository;
  let transactionSpy: sinon.SinonSpy;

  beforeEach(() => {
    sandbox = sinon.createSandbox();

    const firestoreStubInstance = createSinonStub(FirestoreGateway, sandbox);
    firestoreStub = firestoreStubInstance;

    const schemaStubInstance = createSinonStub(SchemaValidator, sandbox);
    storedCollectionsRepo = new StoredCollectionsRepository(firestoreStubInstance, schemaStubInstance);

    // Mocks the transaction function to always run what's is inside the context
    const transactionContext = async (context: any) => {
      await context();
    };

    transactionSpy = sandbox.spy(transactionContext);
    firestoreStub.runTransaction.callsFake(transactionSpy);
  });

  afterEach(() => {
    sandbox.restore();
  });

  describe("setCollections", () => {
    it("should set collections set inside a single transaction", async () => {
      const mockCollection = _newCollection();

      await storedCollectionsRepo.setCollections([mockCollection]);

      assert.ok(firestoreStub.runTransaction.calledOnce);
      assert.ok(transactionSpy.calledOnce);
    });

    it("should throw when raw collections have an invalid format", () => {
      const malformedCollection: StoredPublicCollection = <any>{ id: "id2", foo: "bar" };
      const mockCollections = [_newCollection(), malformedCollection];

      assert.rejects(() => storedCollectionsRepo.setCollections(mockCollections), SerializationError);
    });

    it("should set collections using their raw representation", async () => {
      const mockCollection = _newCollection();
      const expectedId = mockCollection.id;
      const expectedPath = "collections";
      const expectedData = <any>mockCollection;

      await storedCollectionsRepo.setCollections([mockCollection]);
      const { id, path, data } = firestoreStub.setDoc.lastCall.firstArg;

      assert.strictEqual(id, expectedId);
      assert.strictEqual(path, expectedPath);
      assert.strictEqual(data, expectedData);
    });
  });

  describe("deleteCollectionsByIds", () => {
    it("should remove collections inside a single transaction", async () => {
      await storedCollectionsRepo.deleteCollectionsByIds(["any"]);

      assert.ok(firestoreStub.runTransaction.calledOnce);
      assert.ok(transactionSpy.calledOnce);
    });

    it("should remove a collection by its id", async () => {
      const expectedId = "anyId";
      const expectedPath = "collections";

      await storedCollectionsRepo.deleteCollectionsByIds([expectedId]);
      const { id, path } = firestoreStub.deleteDocRecursively.lastCall.firstArg;

      assert.strictEqual(id, expectedId);
      assert.strictEqual(path, expectedPath);
    });
  });

  describe("getAllCollectionsByIds", async () => {
    it("should return deserialized collections", async () => {
      const firstRawCollection = _newCollection({ id: "id1" });
      const secondRawCollection = _newCollection({ id: "id2" });

      firestoreStub.getDoc.withArgs({ id: firstRawCollection.id, path: "collections" }).resolves(firstRawCollection);
      firestoreStub.getDoc.withArgs({ id: secondRawCollection.id, path: "collections" }).resolves(secondRawCollection);
      const collections = await storedCollectionsRepo.getAllCollectionsByIds([
        firstRawCollection.id,
        secondRawCollection.id,
      ]);

      assert.strictEqual(collections.length, 2);
      assert.strictEqual(collections[0]!.id, firstRawCollection.id);
      assert.strictEqual(collections[1]!.id, secondRawCollection.id);
    });

    it("should throw when a collection is not in the expected schema format", () => {
      const firstRawCollection = _newCollection({ id: "id1" });
      const secondRawCollection = { id: "2", foo: "bar" };

      firestoreStub.getDoc.withArgs({ id: firstRawCollection.id, path: "collections" }).resolves(firstRawCollection);
      firestoreStub.getDoc.withArgs({ id: secondRawCollection.id, path: "collections" }).resolves(secondRawCollection);

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
    description: "Description",
    tags: [],
    category: "Category",
    contributors: [],
    resources: [],
    memosAmount: 1,
    memosOrder: ["memo1", "memo2", "memo3"],
  };
}
