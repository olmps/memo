import { registerTSPaths } from "./ts-paths";
// Always make sure that this is called before any other import/declaration.
registerTSPaths();

import * as functions from "firebase-functions";

export const dummyFunction = functions.https.onRequest(async (_, res) => {
  res.status(200).send("dummy.value");
});
