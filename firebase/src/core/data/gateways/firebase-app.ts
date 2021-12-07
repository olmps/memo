import * as admin from "firebase-admin";

export function initializeFirebase(options: { isLocalDevelopment: boolean }): admin.app.App {
  if (options.isLocalDevelopment) {
    process.env["FIRESTORE_EMULATOR_HOST"] = "localhost:8080";
  }

  return admin.initializeApp();
}
