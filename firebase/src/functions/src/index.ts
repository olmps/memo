import * as functions from "firebase-functions";

const androidPackageId = 'com.olmps.memoClient';

export const appleSignInCallback = functions.https.onRequest((req, res) => {
  try {
    const body = new URLSearchParams(req.body).toString();
    const url = `intent://callback?${body}#Intent;package=${androidPackageId};scheme=signinwithapple;end`;
    res.redirect(url);
  } catch (validationError) {
    res.status(400).send('Malformed data in the request body');
  }
});

export const deleteCollection = functions.https.onRequest((req, res) => {
  try {
    // 1. Check if request is authenticated + has the collection ID and the user ID.
    // 2. Request for the doc at user ID + collection ID to be recursivelly deleted.

    res.status(200).send();
  } catch (validationError) {
    res.status(400).send('Malformed data in the request body');
  }
});
