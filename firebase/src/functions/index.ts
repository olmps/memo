import * as functions from "firebase-functions";
import { dummy } from "../core/dummy";

export const dummyFunction = functions.https.onRequest((_, res) => {
  res.status(200).send(dummy.value);
});
