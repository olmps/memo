import * as admin from "firebase-admin";
import { EnvGateway } from "./env-gateway";

export function initializeFirebase(env: EnvGateway): admin.app.App {
  if (env.isLocalDevelopment) {
    process.env["FIRESTORE_EMULATOR_HOST"] = "localhost:8080";
  }

  const serviceAccount = env.firebaseServiceAccount;
  return admin.initializeApp({
    projectId: serviceAccount.projectId,
    credential: admin.credential.cert({
      clientEmail: serviceAccount.clientEmail,
      projectId: serviceAccount.projectId,
      privateKey: serviceAccount.privateKey,
    }),
  });
}
