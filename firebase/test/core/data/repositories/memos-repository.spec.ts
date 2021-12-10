import * as assert from "assert";
import * as sinon from "sinon";
import { FirestoreGateway } from "#data/gateways/firestore-gateway";
import { MemosRepository } from "#data/repositories/memos-repository";
import { SchemaValidator } from "#data/schemas/schema-validator";
import { Memo } from "#domain/models/memo";
import SerializationError from "#faults/errors/serialization-error";
import createSinonStub from "#test/sinon-stub";

describe("MemosRepository", () => {
  let sandbox: sinon.SinonSandbox;
  let firestoreStub: sinon.SinonStubbedInstance<FirestoreGateway>;
  let schemaStub: sinon.SinonStubbedInstance<SchemaValidator>;
  let memosRepo: MemosRepository;
  let transactionSpy: sinon.SinonSpy;

  beforeEach(() => {
    sandbox = sinon.createSandbox();

    const firestoreStubInstance = createSinonStub(FirestoreGateway, sandbox);
    firestoreStub = firestoreStubInstance;

    const schemaValidatorStub = createSinonStub(SchemaValidator, sandbox);
    schemaStub = schemaValidatorStub;

    memosRepo = new MemosRepository(firestoreStubInstance, schemaValidatorStub);

    // Mocks the transaction function to always run what's is inside the context
    const transactionContext = async (context: any) => {
      await context();
    };

    transactionSpy = sandbox.spy(transactionContext);
    firestoreStub.runTransaction.callsFake(transactionSpy);
  });

  afterEach(() => {
    sandbox.resetHistory();
  });

  describe("setMemos", async () => {
    const fakeCollectionId = "collectionId1";
    const fakeMemo = newRawMemo({ id: "id1" });
    const memosPerCollection = newMemosPerCollection(fakeCollectionId, [fakeMemo]);

    it("should update all memos inside a single transaction", async () => {
      await memosRepo.setMemos(memosPerCollection);

      assert.ok(firestoreStub.runTransaction.calledOnce);
      assert.ok(transactionSpy.calledOnce);
      assert.ok(schemaStub.validateObject.calledOnce);
    });

    it("should throw when raw memos have an invalid format", async () => {
      const fakeError = new SerializationError({ message: "Error Message" });
      const fakeMemosPerCollection = newMemosPerCollection(fakeCollectionId, [fakeMemo]);

      schemaStub.validateObject.throws(fakeError);

      await assert.rejects(() => memosRepo.setMemos(fakeMemosPerCollection), fakeError);
    });

    it("should update a memo using its raw representation", async () => {
      const expectedId = fakeMemo.id;
      const expectedPath = `collections/${fakeCollectionId}/memos`;
      const expectedData = <any>fakeMemo;

      await memosRepo.setMemos(memosPerCollection);
      const { id, path, data } = firestoreStub.setDoc.lastCall.firstArg;

      assert.strictEqual(id, expectedId);
      assert.strictEqual(path, expectedPath);
      assert.strictEqual(data, expectedData);
      assert.ok(schemaStub.validateObject.calledOnce);
    });
  });

  describe("removeMemosByIds", () => {
    const fakeCollectionId = "collectionId1";
    const fakeMemoId = "id1";
    const memosIdsPerCollection = newMemosIdsPerCollection(fakeCollectionId, [fakeMemoId]);

    it("should remove all memos inside a single transaction", async () => {
      await memosRepo.removeMemosByIds(memosIdsPerCollection);

      assert.ok(firestoreStub.runTransaction.calledOnce);
      assert.ok(transactionSpy.calledOnce);
    });

    it("should remove a memo by its id", async () => {
      const expectedId = fakeMemoId;
      const expectedPath = `collections/${fakeCollectionId}/memos`;

      await memosRepo.removeMemosByIds(memosIdsPerCollection);
      const { id, path } = firestoreStub.deleteDoc.lastCall.firstArg;

      assert.strictEqual(id, expectedId);
      assert.strictEqual(path, expectedPath);
    });
  });

  describe("getAllMemos", async () => {
    it("should return a list of deserialized memos", async () => {
      const firstRawMemo = newRawMemo({ id: "1", question: "Question 1", answer: "Answer 1" });
      const secondRawMemo = newRawMemo({ id: "2", question: "Question 2", answer: "Answer 2" });

      firestoreStub.getCollection.resolves([firstRawMemo, secondRawMemo]);
      const memos = await memosRepo.getAllMemos("any");

      assert.strictEqual(memos.length, 2);
      assert.strictEqual(memos[0]!.id, firstRawMemo.id);
      assert.strictEqual(memos[1]!.id, secondRawMemo.id);
      assert.ok(schemaStub.validateObject.calledTwice);
    });

    it("should throw when a memo is not in the expected schema format", async () => {
      const fakeMemo = newRawMemo({ id: "1", question: "Question 1", answer: "Answer 1" });
      const fakeError = new SerializationError({ message: "Error Message" });

      firestoreStub.getCollection.resolves([fakeMemo]);
      schemaStub.validateObject.throws(fakeError);

      await assert.rejects(() => memosRepo.getAllMemos("any"), fakeError);
    });
  });
});

function newMemosPerCollection(collectionId: string, memos: Memo[]): Map<string, Memo[]> {
  return new Map<string, Memo[]>([[collectionId, memos]]);
}

function newMemosIdsPerCollection(collectionId: string, memosIds: string[]): Map<string, string[]> {
  return new Map<string, string[]>([[collectionId, memosIds]]);
}

function newRawMemo(props?: { id?: string; question?: string; answer?: string }): Memo {
  return {
    id: props?.id ?? "any",
    question: [
      {
        insert: props?.question ?? "Question string",
      },
    ],
    answer: [
      {
        insert: props?.answer ?? "Answer string",
      },
    ],
  };
}
