import * as functions from 'firebase-functions';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const admin = require('firebase-admin');
admin.initializeApp();

var defaultStorage = admin.storage();

exports.removeProfilePictureWhenDeletingUserData = functions.firestore
  .document('issues/{issueId}')
  .onDelete((snap, context) => {
    const issueId = context.params.issueId;

    const bucket = defaultStorage.bucket();
    const file = bucket.file('images/' + issueId + '.jpg');

    // Delete the file
    return file.delete();
  });
