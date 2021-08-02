import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "../../utils";

describe("users/{userId}/collections/{doc}/memos", () => {
  const collectionId = (userId: string) => `users/${userId}/collections/any_id/memos`;
  let collectionsMemosCollection: utils.CollectionReference;
  let firestore: utils.ClientFirestore;

  describe("owner users", () => {
    before(async () => {
      firestore = await utils.createMyFirestore();
      collectionsMemosCollection = firestore.collection(collectionId(utils.myFirestoreUid));
    });

    it("should be able to read its collections' memos", async () => {
      await rulesTesting.assertSucceeds(collectionsMemosCollection.get());
    });

    it("should be denied to read other collections' memos", async () => {
      const othersCollections = firestore.collection(collectionId("any"));
      await rulesTesting.assertFails(othersCollections.get());
    });

    it("should be able to write its collections' memos", async () => {
      await rulesTesting.assertSucceeds(collectionsMemosCollection.doc().set({ any: "any" }));
    });

    it("should be denied to write other collections' memos", async () => {
      const othersCollections = firestore.collection(collectionId("any"));
      await rulesTesting.assertFails(othersCollections.get());
    });
  });
});
