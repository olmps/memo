import * as utils from "@test/firebase-rules/utils";

// Load the required test environment dependencies before anything else.
before(async () => {
  await utils.loadTestEnvironment();
});

// Clear all firestore data after each test.
afterEach(async () => {
  await utils.clearFirestore();
});

// Make sure that there are no hanging resources after running all tests.
after(async () => {
  await utils.cleanup();
});
