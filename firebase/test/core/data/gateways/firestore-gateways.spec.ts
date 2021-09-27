/* eslint-disable @typescript-eslint/no-explicit-any */
import * as assert from "assert";
import * as sinon from "sinon";
import { FirestoreGateway, QueryFilter } from "@data/gateways/firestore-gateway";
import * as firebase from "firebase-admin";
import createSinonStub from "@test/sinon-stub";
import FirebaseFirestoreError from "@faults/errors/firebase-firestore-error";

// TODO(matuella): Improve readability:
// 1. Can't export type alias, meaning that it's really verbose to write related types.
// 2. Improve type-narrowing. Using "as any" as a workaround in a couple of cases.

describe("FirestoreGateway", () => {
  type FakeCollection = "collection";

  let firestoreMock: sinon.SinonStubbedInstance<firebase.firestore.Firestore>;
  let firestoreGateway: FirestoreGateway<FakeCollection>;

  beforeEach(() => {
    firestoreMock = createSinonStub(firebase.firestore.Firestore);
    firestoreGateway = new FirestoreGateway<FakeCollection>(firestoreMock as firebase.firestore.Firestore);
  });

  afterEach(() => {
    sinon.restore();
  });

  function createTransactionMock(): sinon.SinonStubbedInstance<firebase.firestore.Transaction> {
    const transactionMock = createSinonStub(firebase.firestore.Transaction);
    firestoreMock.runTransaction.callsFake((fn) => {
      return fn(transactionMock);
    });

    return transactionMock;
  }

  function createCollectionMock(): sinon.SinonStubbedInstance<firebase.firestore.CollectionReference> {
    const collectionMock = createSinonStub(firebase.firestore.CollectionReference);
    firestoreMock.collection.withArgs("collection").returns(collectionMock as any);

    return collectionMock;
  }

  const fakeObject = { test: "object" };
  const fakeDocId = "any";

  describe("read", () => {
    let querySnapshotMock: sinon.SinonStubbedInstance<firebase.firestore.QuerySnapshot>;
    let docDataMock: sinon.SinonStubbedInstance<firebase.firestore.DocumentSnapshot>;

    function createQuerySnapshotMock() {
      const querySnapshotMock = createSinonStub(firebase.firestore.QuerySnapshot);
      sinon.replaceGetter(querySnapshotMock, "docs", () => [docDataMock] as firebase.firestore.QueryDocumentSnapshot[]);
      return querySnapshotMock;
    }

    function createDocumentSnapshotMock(
      returnedData: any
    ): sinon.SinonStubbedInstance<firebase.firestore.DocumentSnapshot> {
      const docSnapshotMock = createSinonStub(firebase.firestore.DocumentSnapshot);
      docSnapshotMock.data.returns(returnedData);

      return docSnapshotMock;
    }

    describe("getCollectionGroup", () => {
      let collectionGroupMock: sinon.SinonStubbedInstance<firebase.firestore.CollectionGroup>;
      const fakeFilters: QueryFilter[] = [{ field: "any", comparison: ">", value: "any" }];

      beforeEach(() => {
        docDataMock = createDocumentSnapshotMock(fakeObject);
        querySnapshotMock = createQuerySnapshotMock();

        collectionGroupMock = createSinonStub(firebase.firestore.CollectionGroup);
        firestoreMock.collectionGroup.withArgs("collection").returns(collectionGroupMock as any);

        collectionGroupMock.get.resolves(querySnapshotMock);
      });

      it("should return documents with an unfiltered call", async () => {
        const result = await firestoreGateway.getCollectionGroup("collection");

        assert(result.length === 1);
        assert.deepStrictEqual(result[0], fakeObject);
        assert(collectionGroupMock.get.calledOnce);
      });

      it("should return documents with a filtered call", async () => {
        collectionGroupMock.where
          .withArgs(fakeFilters[0]!.field, fakeFilters[0]!.comparison, fakeFilters[0]!.value)
          .returns(collectionGroupMock as any);

        const val = await firestoreGateway.getCollectionGroup("collection", fakeFilters);

        assert(val.length === 1);
        assert.deepStrictEqual(val[0], fakeObject);
        assert(collectionGroupMock.get.calledOnce);
      });

      it("should reject when query get throws", async () => {
        collectionGroupMock.get.rejects();

        await assert.rejects(() => firestoreGateway.getCollectionGroup("collection"), FirebaseFirestoreError);
        assert(collectionGroupMock.get.calledOnce);
      });

      it("should get from the transaction when available", async () => {
        const transactionMock = createTransactionMock();
        transactionMock.get.withArgs(collectionGroupMock as any).resolves(querySnapshotMock as any);

        await firestoreGateway.runTransaction(async () => {
          await firestoreGateway.getCollectionGroup("collection");
        });

        assert(collectionGroupMock.get.notCalled);
        assert(transactionMock.get.calledOnce);
      });
    });

    describe("getCollection", () => {
      let collectionMock: sinon.SinonStubbedInstance<firebase.firestore.CollectionReference>;

      beforeEach(() => {
        docDataMock = createDocumentSnapshotMock(fakeObject);
        querySnapshotMock = createQuerySnapshotMock();
        collectionMock = createCollectionMock();
      });

      it("should return documents with an unfiltered call", async () => {
        collectionMock.get.resolves(querySnapshotMock);
        const val = await firestoreGateway.getCollection("collection");

        assert(val.length === 1);
        assert.deepStrictEqual(val[0], fakeObject);
        assert(collectionMock.get.calledOnce);
      });

      it("should return documents with a filtered call", async () => {
        collectionMock.get.resolves(querySnapshotMock);
        const fakeFilters: QueryFilter[] = [{ field: "any", comparison: ">", value: "any" }];
        collectionMock.where
          .withArgs(fakeFilters[0]!.field, fakeFilters[0]!.comparison, fakeFilters[0]!.value)
          .returns(collectionMock as any);

        const val = await firestoreGateway.getCollection("collection", fakeFilters);

        assert(val.length === 1);
        assert.deepStrictEqual(val[0], fakeObject);
        assert(collectionMock.get.calledOnce);
      });

      it("should reject when query get throws", async () => {
        collectionMock.get.rejects();

        await assert.rejects(() => firestoreGateway.getCollection("collection"), FirebaseFirestoreError);
        assert(collectionMock.get.calledOnce);
      });

      it("should get from the transaction when available", async () => {
        collectionMock.get.resolves(querySnapshotMock);

        const transactionMock = createTransactionMock();
        transactionMock.get.withArgs(collectionMock as any).resolves(querySnapshotMock as any);

        await firestoreGateway.runTransaction(async () => {
          await firestoreGateway.getCollection("collection");
        });

        assert(collectionMock.get.notCalled);
        assert(transactionMock.get.calledOnce);
      });
    });

    describe("getDoc", () => {
      let collectionMock: sinon.SinonStubbedInstance<firebase.firestore.CollectionReference>;
      let collectionDocMock: sinon.SinonStubbedInstance<firebase.firestore.DocumentReference>;

      beforeEach(() => {
        collectionDocMock = createSinonStub(firebase.firestore.DocumentReference);
        collectionMock = createCollectionMock();
        collectionMock.doc.withArgs(fakeDocId).returns(collectionDocMock as any);
      });

      it("should return an existing document", async () => {
        docDataMock = createDocumentSnapshotMock(fakeObject);
        collectionDocMock.get.resolves(docDataMock);

        const val = await firestoreGateway.getDoc({ id: fakeDocId, path: "collection" });

        assert.deepStrictEqual(val, fakeObject);
        assert(collectionDocMock.get.calledOnce);
      });

      it("should return null when no document is found", async () => {
        docDataMock = createDocumentSnapshotMock(undefined);
        collectionDocMock.get.resolves(docDataMock);

        const val = await firestoreGateway.getDoc({ id: fakeDocId, path: "collection" });

        assert.deepStrictEqual(val, null);
        assert(collectionDocMock.get.calledOnce);
      });

      it("should reject when doc get throws", async () => {
        collectionDocMock.get.rejects();

        await assert.rejects(
          () => firestoreGateway.getDoc({ id: fakeDocId, path: "collection" }),
          FirebaseFirestoreError
        );
        assert(collectionDocMock.get.calledOnce);
      });

      it("should get from the transaction when available", async () => {
        const transactionMock = createTransactionMock();
        transactionMock.get.withArgs(collectionDocMock).resolves(docDataMock);

        await firestoreGateway.runTransaction(async () => {
          await firestoreGateway.getDoc({ id: fakeDocId, path: "collection" });
        });

        assert(collectionDocMock.get.notCalled);
        assert(transactionMock.get.calledOnce);
      });
    });
  });

  describe("write", () => {
    describe("updateDoc", () => {
      let collectionMock: sinon.SinonStubbedInstance<firebase.firestore.CollectionReference>;
      let collectionDocMock: sinon.SinonStubbedInstance<firebase.firestore.DocumentReference>;

      beforeEach(() => {
        collectionDocMock = createSinonStub(firebase.firestore.DocumentReference);

        collectionMock = createCollectionMock();
        collectionMock.doc.withArgs(fakeDocId).returns(collectionDocMock as any);
      });

      it("should call update in an existing document", async () => {
        collectionDocMock.update.withArgs(fakeObject as any, undefined).resolves();
        await firestoreGateway.updateDoc({ id: fakeDocId, path: "collection", data: fakeObject });

        assert(collectionDocMock.update.calledOnce);
      });

      it("should reject when doc update throws", async () => {
        collectionDocMock.update.rejects();

        await assert.rejects(
          () => firestoreGateway.updateDoc({ id: fakeDocId, path: "collection", data: fakeObject }),
          FirebaseFirestoreError
        );
        assert(collectionDocMock.update.calledOnce);
      });

      it("should update using the transaction when available", async () => {
        collectionDocMock.update.withArgs(fakeObject as any, undefined).resolves();

        const transactionMock = createTransactionMock();
        // Upcasting this stub because it's conflicting with its function, making TS compiler infer the wrong overload.
        (transactionMock.update as sinon.SinonStub).withArgs(collectionDocMock, fakeObject as any).resolves();

        await firestoreGateway.runTransaction(async () => {
          await firestoreGateway.updateDoc({ id: fakeDocId, path: "collection", data: fakeObject });
        });

        assert(collectionDocMock.update.notCalled);
        assert(transactionMock.update.calledOnce);
      });
    });

    describe("createDoc", () => {
      let collectionMock: sinon.SinonStubbedInstance<firebase.firestore.CollectionReference>;
      let collectionDocMock: sinon.SinonStubbedInstance<firebase.firestore.DocumentReference>;

      beforeEach(() => {
        collectionDocMock = createSinonStub(firebase.firestore.DocumentReference);
        collectionDocMock.update.withArgs(fakeObject as any, undefined).resolves();

        collectionMock = createCollectionMock();
        collectionMock.doc.withArgs(fakeDocId).returns(collectionDocMock as any);
      });

      it("should create a new doc", async () => {
        await firestoreGateway.createDoc({ id: fakeDocId, path: "collection", data: fakeObject });

        assert(collectionDocMock.create.calledOnce);
      });

      it("should reject when doc create throws", async () => {
        collectionDocMock.create.rejects();

        await assert.rejects(
          () => firestoreGateway.createDoc({ id: fakeDocId, path: "collection", data: fakeObject }),
          FirebaseFirestoreError
        );
        assert(collectionDocMock.create.calledOnce);
      });

      it("should create using the transaction when available", async () => {
        const transactionMock = createTransactionMock();
        transactionMock.create.withArgs(collectionDocMock, fakeObject as any).resolves();

        await firestoreGateway.runTransaction(async () => {
          await firestoreGateway.createDoc({ id: fakeDocId, path: "collection", data: fakeObject });
        });

        assert(collectionDocMock.create.notCalled);
        assert(transactionMock.create.calledOnce);
      });
    });

    describe("deleteDoc", () => {
      let collectionMock: sinon.SinonStubbedInstance<firebase.firestore.CollectionReference>;
      let collectionDocMock: sinon.SinonStubbedInstance<firebase.firestore.DocumentReference>;

      beforeEach(() => {
        collectionDocMock = createSinonStub(firebase.firestore.DocumentReference);
        collectionDocMock.delete.resolves();

        collectionMock = createCollectionMock();
        collectionMock.doc.withArgs(fakeDocId).returns(collectionDocMock as any);
      });

      it("should delete an existing doc", async () => {
        await firestoreGateway.deleteDoc({ id: fakeDocId, path: "collection" });

        assert(collectionDocMock.delete.calledOnce);
      });

      it("should reject when doc delete throws", async () => {
        collectionDocMock.delete.rejects();

        await assert.rejects(
          () => firestoreGateway.deleteDoc({ id: fakeDocId, path: "collection" }),
          FirebaseFirestoreError
        );
        assert(collectionDocMock.delete.calledOnce);
      });

      it("should delete using the transaction when available", async () => {
        const transactionMock = createTransactionMock();
        transactionMock.delete.resolves();

        await firestoreGateway.runTransaction(async () => {
          await firestoreGateway.deleteDoc({ id: fakeDocId, path: "collection" });
        });

        assert(collectionDocMock.delete.notCalled);
        assert(transactionMock.delete.calledOnce);
      });
    });

    describe("runTransaction", () => {
      it("should reject when any throw occurs in context", async () => {
        createTransactionMock();

        await assert.rejects(
          () =>
            firestoreGateway.runTransaction(async () => {
              throw Error();
            }),
          FirebaseFirestoreError
        );
      });

      it("should clear transaction when any throw occurs in context", async () => {
        createTransactionMock();

        try {
          await firestoreGateway.runTransaction(async () => {
            throw Error();
          });
        } catch (_) {
          assert(!firestoreGateway.hasOngoingTransaction);
        }
      });

      it("should clear transaction after context is fulfilled", async () => {
        createTransactionMock();

        const hadTransaction = await firestoreGateway.runTransaction(async () => {
          return firestoreGateway.hasOngoingTransaction;
        });

        assert(hadTransaction);
        assert(!firestoreGateway.hasOngoingTransaction);
      });
    });
  });
});
