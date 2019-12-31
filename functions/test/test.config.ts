import functions from 'firebase-functions-test'
import * as uninitializedAdmin from 'firebase-admin'
// import serviceAccount from './service-account.json'
const serviceAccount = require(__dirname + '/./service-account.json')

const conf = {
  databaseURL: "https://my-town-test-40433.firebaseio.com",
  projectId: "my-town-test-40433",
  storageBucket: "my-town-test-40433.appspot.com",
}

const admin = uninitializedAdmin.initializeApp({
  credential: uninitializedAdmin.credential.cert(serviceAccount as any),
  ...conf
})

// admin.initializeApp();
// Online Testing
const testEnv = functions({
  ...conf
}, __dirname + '/./service-account.json')

// Provide 3rd party API keys
testEnv.mockConfig({});

export {admin, testEnv}