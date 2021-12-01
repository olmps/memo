import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "#test/firebase-rules/utils";

describe("users/{userId}/collections_categories", () => {
  const collectionId = (userId: string) => `users/${userId}/collections_categories`;
  let collectionsCategoriesRef: utils.CollectionReference;
  let firestore: utils.Firestore;

  describe("owner users", () => {
    before(() => {
      firestore = utils.createMyFirestore();
      collectionsCategoriesRef = firestore.collection(collectionId(utils.myFirestoreUid));
    });

    it("should be able to read its collections categories", async () => {
      await rulesTesting.assertSucceeds(collectionsCategoriesRef.get());
    });

    it("should be denied to read other collections categories", async () => {
      const othersCategories = firestore.collection(collectionId("any"));
      await rulesTesting.assertFails(othersCategories.get());
    });

    it("should be able to write its collections categories", async () => {
      await rulesTesting.assertSucceeds(collectionsCategoriesRef.add({}));
      await rulesTesting.assertSucceeds(collectionsCategoriesRef.doc().set({ any: "any" }));
    });

    it("should be denied to write other collections categories", async () => {
      const othersCategories = firestore.collection(collectionId("any"));

      await rulesTesting.assertFails(othersCategories.add({}));
      await rulesTesting.assertFails(othersCategories.doc().set({ any: "any" }));
    });
  });
});
