import functions from 'firebase-functions-test'
import * as uninitializedAdmin from 'firebase-admin'
// import serviceAccount from './service-account.json'
const serviceAccount = require(__dirname + '/../service-account.json')

const conf = {
  databaseURL: "https://my-town-ba556.firebaseio.com",
  projectId: "my-town-ba556",
  storageBucket: "my-town-ba556.appspot.com",
}

const admin = uninitializedAdmin.initializeApp({
  credential: uninitializedAdmin.credential.cert(serviceAccount as any),
  ...conf
})

// admin.initializeApp();
// Online Testing
const testEnv = functions({
  ...conf
}, __dirname + '/../service-account.json')

// Provide 3rd party API keys
testEnv.mockConfig({});

export {admin, testEnv}