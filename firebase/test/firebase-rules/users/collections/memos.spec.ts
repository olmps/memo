import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "@test/firebase-rules/utils";

describe("users/{userId}/collections/{doc}/memos", () => {
  const collectionId = (userId: string) => `users/${userId}/collections/any_id/memos`;
  let collectionsMemosCollection: utils.CollectionReference;
  let firestore: utils.Firestore;

  describe("owner users", () => {
    before(() => {
      firestore = utils.createMyFirestore();
      collectionsMemosCollection = firestore.collection(collectionId(utils.myFirestoreUid));
    });

    it("should be able to read its collection memos", async () => {
      await rulesTesting.assertSucceeds(collectionsMemosCollection.get());
    });

    it("should be denied to read other collection memos", async () => {
      const othersCollections = firestore.collection(collectionId("any"));
      await rulesTesting.assertFails(othersCollections.get());
    });

    it("should be able to write its collection memos", async () => {
      await rulesTesting.assertSucceeds(collectionsMemosCollection.add({}));
      await rulesTesting.assertSucceeds(collectionsMemosCollection.doc().set({ any: "any" }));
    });

    it("should be denied to write other collection memos", async () => {
      const othersMemos = firestore.collection(collectionId("any"));

      await rulesTesting.assertFails(othersMemos.add({}));
      await rulesTesting.assertFails(othersMemos.doc().set({ any: "any" }));
    });
  });
});
