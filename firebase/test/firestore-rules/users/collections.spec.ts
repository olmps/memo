import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "../utils";

describe("users/{userId}/collections", () => {
  const collectionId = (userId: string) => `users/${userId}/collections`;
  let collectionsRef: utils.CollectionReference;
  let firestore: utils.ClientFirestore;

  describe("owner users", () => {
    before(() => {
      firestore = utils.createMyFirestore();
      collectionsRef = firestore.collection(collectionId(utils.myFirestoreUid));
    });

    it("should be able to read its collections", async () => {
      await rulesTesting.assertSucceeds(collectionsRef.get());
    });

    it("should be denied to read other collections", async () => {
      const othersCollections = firestore.collection(collectionId("any"));
      await rulesTesting.assertFails(othersCollections.get());
    });

    it("should be able to write its collections", async () => {
      await rulesTesting.assertSucceeds(collectionsRef.add({}));
      await rulesTesting.assertSucceeds(collectionsRef.doc().set({ any: "any" }));
    });

    it("should be denied to write other collections", async () => {
      const othersCollections = firestore.collection(collectionId("any"));

      await rulesTesting.assertFails(othersCollections.add({}));
      await rulesTesting.assertFails(othersCollections.doc().set({ any: "any" }));
    });
  });
});
