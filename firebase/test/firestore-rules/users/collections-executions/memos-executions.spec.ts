import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "../../utils";

describe("users/{userId}/collections_executions/{doc}/memos_executions", () => {
  const collectionId = (userId: string) => `users/${userId}/collections_executions/any_id/memos_executions`;
  let memosExecutionsRef: utils.CollectionReference;
  let firestore: utils.ClientFirestore;

  describe("owner users", () => {
    before(() => {
      firestore = utils.createMyFirestore();
      memosExecutionsRef = firestore.collection(collectionId(utils.myFirestoreUid));
    });

    it("should be able to read its collections executions", async () => {
      await rulesTesting.assertSucceeds(memosExecutionsRef.get());
    });

    it("should be denied to read other collections executions", async () => {
      const othersMemosExecutions = firestore.collection(collectionId("any"));
      await rulesTesting.assertFails(othersMemosExecutions.get());
    });

    it("should be able to write its collections executions", async () => {
      await rulesTesting.assertSucceeds(memosExecutionsRef.doc().set({ any: "any" }));
    });

    it("should be denied to write other collections executions", async () => {
      const othersMemosExecutions = firestore.collection(collectionId("any"));
      await rulesTesting.assertFails(othersMemosExecutions.get());
    });
  });
});
