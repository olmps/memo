import * as rulesTesting from "@firebase/rules-unit-testing";
import { TokenOptions } from "@firebase/rules-unit-testing/dist/src/api";

/** Firestore application with client functionalities. */
export type ClientFirestore = firebase.default.firestore.Firestore;

export type CollectionReference = firebase.default.firestore.CollectionReference;

/** Firestore application with admin functionalities. */
export type AdminFirestore = FirebaseFirestore.Firestore;

/** Required and mocked project id, used to instantiate all firebase services */
const PROJECT_ID = "any_id";

/**
 * Instantiates a new `ClientFirestore`, using a default `projectId`.
 *
 * @param auth authenticates this client. If `null`, returns an unauthenticated instance.
 */
export const createFirestore = (auth?: TokenOptions): ClientFirestore =>
  rulesTesting.initializeTestApp({ projectId: PROJECT_ID, auth: auth }).firestore();

/** Instantiates a new `AdminFirestore`, using a default `projectId`. */
export const createAdminFirestore = (): AdminFirestore =>
  rulesTesting.initializeAdminApp({ projectId: PROJECT_ID }).firestore();

/** Clears all Firestore data. */
export const clearFirestore = (): Promise<void> => rulesTesting.clearFirestoreData({ projectId: PROJECT_ID });

/** Mocked Firestore user's uid, used to test ownership of any particular collection/document. */
export const myFirestoreUid = "my_user_id";

/** Syntax-sugar for calling `createFirestore`, authenticated with `myFirestoreUid`. */
export const createMyFirestore = (): ClientFirestore => createFirestore({ uid: myFirestoreUid });
