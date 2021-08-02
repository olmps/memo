import * as utils from "./utils";

// Clears all firestore data after each test
afterEach(async () => {
  await utils.clearFirestore();
});
