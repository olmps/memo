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

  const fakeObject = { test: "object" };

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
  });
});
