import * as fs from "fs";
import * as rulesTesting from "@firebase/rules-unit-testing";

export type Firestore = firebase.default.firestore.Firestore;
export type CollectionReference = firebase.default.firestore.CollectionReference;

/** Required and mocked project id, used to instantiate all firebase services */
const PROJECT_ID = "any";

/**
 * Current test environment for this process.
 *
 * Might be `null` until {@link loadTestEnvironment} is called and done loading.
 */
let env: rulesTesting.RulesTestEnvironment | null = null;

/** Make sure that the current environment is properly setup to run any firebase testing functionality. */
function verifyEnv(): void {
  if (!env) {
    throw Error("To test firebase rules, make sure to call `loadTestEnvironment` first.");
  }
}

/**
 * Provide a `RulesTestContext` for the current {@link env}.
 *
 * @param authorized_user_id Optional authentication for this context.
 */
function createTestContext(authorized_user_id?: string): rulesTesting.RulesTestContext {
  verifyEnv();
  return authorized_user_id ? env!.authenticatedContext(authorized_user_id) : env!.unauthenticatedContext();
}

/**
 * Emulate all dependencies required to test all firebase services rules.
 *
 * This load must be called (and awaited) before running any firebase testing functionality.
 */
export async function loadTestEnvironment(): Promise<void> {
  const rules = fs.readFileSync("./firestore.rules", "utf8");

  env = await rulesTesting.initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules,
    },
  });
}

/** Fake Firestore user uid, used to test ownership of any particular collection/document. */
export const myFirestoreUid = "my_user_id";

/** Create an authenticated firestore context using {@link myFirestoreUid}. */
export const createMyFirestore = (): Firestore => createTestContext(myFirestoreUid).firestore();

/** Create an unauthenticated firestore context. */
export const createFirestore = (): Firestore => createTestContext().firestore();

/** Clear all Firestore data. */
export async function clearFirestore(): Promise<void> {
  verifyEnv();
  await env!.clearFirestore();
}

/** Destroy all resources created while testing, allowing a clean exit. */
export async function cleanup(): Promise<void> {
  verifyEnv();
  await env!.cleanup();
}
