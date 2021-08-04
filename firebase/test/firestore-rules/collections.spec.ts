import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "./utils";

describe("collections/", () => {
  const collectionId = "collections";
  let collectionsRef: utils.CollectionReference;
  let firestore: utils.ClientFirestore;

  describe("authenticated users", () => {
    before(() => {
      firestore = utils.createMyFirestore();
      collectionsRef = firestore.collection(collectionId);
    });

    it("should be able to read collections", async () => {
      await rulesTesting.assertSucceeds(collectionsRef.get());
    });

    it("should be denied to write any collection", async () => {
      await rulesTesting.assertFails(collectionsRef.add({}));
      await rulesTesting.assertFails(collectionsRef.doc().set({ any: "any" }));
    });
  });

  describe("unauthenticated users", () => {
    before(() => {
      firestore = utils.createFirestore();
      collectionsRef = firestore.collection(collectionId);
    });

    it("should be denied to read collections", async () => {
      await rulesTesting.assertFails(collectionsRef.get());
    });

    it("should be denied to write to any collection", async () => {
      await rulesTesting.assertFails(collectionsRef.add({}));
      await rulesTesting.assertFails(collectionsRef.doc().set({ any: "any" }));
    });
  });
});
