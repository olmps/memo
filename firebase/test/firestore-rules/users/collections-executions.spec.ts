import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "../utils";

describe("users/{userId}/collections_executions", () => {
  const collectionId = (userId: string) => `users/${userId}/collections_executions`;
  let collectionsExecutionsRef: utils.CollectionReference;
  let firestore: utils.ClientFirestore;

  describe("owner users", () => {
    before(() => {
      firestore = utils.createMyFirestore();
      collectionsExecutionsRef = firestore.collection(collectionId(utils.myFirestoreUid));
    });

    it("should be able to read its collections executions", async () => {
      await rulesTesting.assertSucceeds(collectionsExecutionsRef.get());
    });

    it("should be denied to read other collections executions", async () => {
      const othersExecutions = firestore.collection(collectionId("any"));
      await rulesTesting.assertFails(othersExecutions.get());
    });

    it("should be able to write its collections executions", async () => {
      await rulesTesting.assertSucceeds(collectionsExecutionsRef.add({}));
      await rulesTesting.assertSucceeds(collectionsExecutionsRef.doc().set({ any: "any" }));
    });

    it("should be denied to write other collections executions", async () => {
      const othersExecutions = firestore.collection(collectionId("any"));

      await rulesTesting.assertFails(othersExecutions.add({}));
      await rulesTesting.assertFails(othersExecutions.doc().set({ any: "any" }));
    });
  });
});
