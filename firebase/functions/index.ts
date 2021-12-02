import * as functions from "firebase-functions";

export const dummyFunction = functions.https.onRequest(async (_, res) => {
  res.status(200).send("dummy-response");
});
