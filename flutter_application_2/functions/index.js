const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();


exports.sendNotification = functions.https.onRequest(async (req, res) => {
  const tokens = req.body.tokens;
  const title = req.body.title;
  const body = req.body.body;

  const message = {
    notification: {
      title: title,
      body: body,
    },
    tokens: tokens,
  };

  try {
    const response = await admin.messaging().sendMulticast(message);
    res.status(200).send(`Successfully sent message: ${response}`);
  } catch (error) {
    res.status(500).send(`Error sending message: ${error}`);
  }
});
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
