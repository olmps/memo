import * as admin from "firebase-admin";

// TODO: Properly initialize this, taking into consideration the environment
process.env["FIRESTORE_EMULATOR_HOST"] = "localhost:8080";
export const app = admin.initializeApp({ projectId: "test-rpoj" });
