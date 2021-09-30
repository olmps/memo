import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "./utils";

describe("databases/{database}/documents/", () => {
  const randomCollectionId = "any-random-collection";
  const randomDocId = "random-doc-id";
  let randomCollection: utils.CollectionReference;
  let firestore: utils.ClientFirestore;

  describe("authenticated users", () => {
    before(() => {
      firestore = utils.createMyFirestore();
      randomCollection = firestore.collection(randomCollectionId);
    });

    it("should be denied to read an unknown collection", async () => {
      await rulesTesting.assertFails(randomCollection.get());
      await rulesTesting.assertFails(randomCollection.doc(randomDocId).get());
    });

    it("should be denied to write an unknown collection", async () => {
      await rulesTesting.assertFails(randomCollection.add({}));
      await rulesTesting.assertFails(randomCollection.doc(randomDocId).set({}));
    });
  });

  describe("unauthenticated users", () => {
    before(() => {
      firestore = utils.createFirestore();
      randomCollection = firestore.collection(randomCollectionId);
    });

    it("should be denied to read an unknown collection", async () => {
      await rulesTesting.assertFails(randomCollection.get());
      await rulesTesting.assertFails(randomCollection.doc(randomDocId).get());
    });

    it("should be denied to write an unknown collection", async () => {
      await rulesTesting.assertFails(randomCollection.add({}));
      await rulesTesting.assertFails(randomCollection.doc(randomDocId).set({}));
    });
  });
});
