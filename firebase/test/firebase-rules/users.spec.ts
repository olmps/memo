import * as rulesTesting from "@firebase/rules-unit-testing";
import * as utils from "#test/firebase-rules/utils";

describe("users/", () => {
  const collectionId = "users";
  let usersRef: utils.CollectionReference;
  let firestore: utils.Firestore;

  describe("owner users", () => {
    before(() => {
      firestore = utils.createMyFirestore();
      usersRef = firestore.collection(collectionId);
    });

    it("should be able to read its respective document", async () => {
      await rulesTesting.assertSucceeds(usersRef.doc(utils.myFirestoreUid).get());
    });

    it("should be denied to read other documents", async () => {
      await rulesTesting.assertFails(usersRef.get());
      await rulesTesting.assertFails(usersRef.doc("any").get());
    });

    it("should be able to write its respective document", async () => {
      await rulesTesting.assertSucceeds(usersRef.doc(utils.myFirestoreUid).set({ any: "any" }));
    });

    it("should be denied to write other documents", async () => {
      await rulesTesting.assertFails(usersRef.add({}));
      await rulesTesting.assertFails(usersRef.doc("any").set({ any: "any" }));
    });
  });
});
