import 'jest';
// import '@types/jest'; // TODO: only for vscode to work, cos it sucks
import * as functions from 'firebase-functions-test';
import * as uninitializedAdmin from 'firebase-admin';
const serviceAccount = require('./service-account.json');

const admin = uninitializedAdmin.initializeApp({
  credential: uninitializedAdmin.credential.cert(serviceAccount),
  databaseURL: "https://my-town-test-40433.firebaseio.com",
  projectId: "my-town-test-40433",
  storageBucket: "my-town-test-40433.appspot.com",
});

// admin.initializeApp();
// Online Testing
const testEnv = functions({
  databaseURL: "https://my-town-test-40433.firebaseio.com",
  projectId: "my-town-test-40433",
  storageBucket: "my-town-test-40433.appspot.com",
}, './service-account.json');

// Provide 3rd party API keys
testEnv.mockConfig({});

import { votesAggregate } from '../src/votes';

describe('Vote for issue', () => {
  let wrapped: any;
  const testIssueId = 'issue1';
  // Applies only to tests in this describe block
  beforeAll(() => {
    wrapped = testEnv.wrap(votesAggregate);
  });

  afterAll(async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).delete()
    testEnv.cleanup();
  });

  test('it upvotes an issue', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 0 });
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
    }, 'issue-votes/...');
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true,
    }, 'issue-votes/...');
    const change = testEnv.makeChange(before, after);

    await wrapped(change);

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get();

    expect(issueDoc?.data()?.upvotes).toBe(1);
    expect(issueDoc?.data()?.downvotes).toBeUndefined();
  });

  test('it downvotes an issue', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 0 });
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId
    }, 'issue-votes/...');
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: false
    }, 'issue-votes/...');
    const change = testEnv.makeChange(before, after);

    await wrapped(change);

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get();

    expect(issueDoc?.data()?.upvotes).toBe(0);
    expect(issueDoc?.data()?.downvotes).toBe(1);
  });

  test('it downvotes an upvoted', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 1 });
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true
    }, 'issue-votes/...');
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: false
    }, 'issue-votes/...');
    const change = testEnv.makeChange(before, after);

    await wrapped(change);

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get();

    expect(issueDoc?.data()?.upvotes).toBe(0);
    expect(issueDoc?.data()?.downvotes).toBe(1);
  });
  
  test('it upvotes a downvoted', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ downvotes: 1 });
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: false
    }, 'issue-votes/...');
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true
    }, 'issue-votes/...');
    const change = testEnv.makeChange(before, after);

    await wrapped(change);

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get();

    expect(issueDoc?.data()?.upvotes).toBe(1);
    expect(issueDoc?.data()?.downvotes).toBe(0);
  });

  test('it unvotes an upvoted', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 1 });
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true
    }, 'issue-votes/...');
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
    }, 'issue-votes/...');
    const change = testEnv.makeChange(before, after);

    await wrapped(change);

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get();

    expect(issueDoc?.data()?.upvotes).toBe(0);
    expect(issueDoc?.data()?.downvotes).toBeUndefined();
  });

  test('it unvotes a downvoted', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ downvotes: 1 });
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: false
    }, 'issue-votes/...');
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
    }, 'issue-votes/...');
    const change = testEnv.makeChange(before, after);

    await wrapped(change);

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get();

    expect(issueDoc?.data()?.upvotes).toBeUndefined();
    expect(issueDoc?.data()?.downvotes).toBe(0);
  });
});
