import 'jest'
import { admin, testEnv } from './test.config'

import { votesAggregate } from '../src/votes'
import { uuid } from 'uuidv4'
import { WrappedFunction } from 'firebase-functions-test/lib/main'

describe('Vote for issue', () => {
  let wrapped: WrappedFunction
  const testIssueId = uuid()
  // Applies only to tests in this describe block
  beforeAll(() => {
    wrapped = testEnv.wrap(votesAggregate)
  })

  afterAll(async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).delete()
    testEnv.cleanup()
  })

  test('it upvotes an issue', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 0 })
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
    }, 'issue-votes/...')
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true,
    }, 'issue-votes/...')
    const change = testEnv.makeChange(before, after)

    await wrapped(change)

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get()

    expect(issueDoc?.data()?.upvotes).toBe(1)
    expect(issueDoc?.data()?.downvotes).toBeUndefined()
  })

  test('it downvotes an issue', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 0 })
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId
    }, 'issue-votes/...')
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: false
    }, 'issue-votes/...')
    const change = testEnv.makeChange(before, after)

    await wrapped(change)

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get()

    expect(issueDoc?.data()?.upvotes).toBe(0)
    expect(issueDoc?.data()?.downvotes).toBe(1)
  })

  test('it downvotes an upvoted', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 1 })
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true
    }, 'issue-votes/...')
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: false
    }, 'issue-votes/...')
    const change = testEnv.makeChange(before, after)

    await wrapped(change)

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get()

    expect(issueDoc?.data()?.upvotes).toBe(0)
    expect(issueDoc?.data()?.downvotes).toBe(1)
  })

  test('it upvotes a downvoted', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ downvotes: 1 })
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: false
    }, 'issue-votes/...')
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true
    }, 'issue-votes/...')
    const change = testEnv.makeChange(before, after)

    await wrapped(change)

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get()

    expect(issueDoc?.data()?.upvotes).toBe(1)
    expect(issueDoc?.data()?.downvotes).toBe(0)
  })

  test('it unvotes an upvoted', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 1 })
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true
    }, 'issue-votes/...')
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
    }, 'issue-votes/...')
    const change = testEnv.makeChange(before, after)

    await wrapped(change)

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get()

    expect(issueDoc?.data()?.upvotes).toBe(0)
    expect(issueDoc?.data()?.downvotes).toBeUndefined()
  })

  test('it unvotes a downvoted', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ downvotes: 1 })
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: false
    }, 'issue-votes/...')
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
    }, 'issue-votes/...')
    const change = testEnv.makeChange(before, after)

    await wrapped(change)

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get()

    expect(issueDoc?.data()?.upvotes).toBeUndefined()
    expect(issueDoc?.data()?.downvotes).toBe(0)
  })

  test('nothing should happen when vote is changed to the same value', async () => {
    await admin.firestore().doc(`issues/${testIssueId}`).set({ upvotes: 1 })
    const before = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true
    }, 'issue-votes/...')
    const after = testEnv.firestore.makeDocumentSnapshot({
      issueId: testIssueId,
      upvote: true
    }, 'issue-votes/...')
    const change = testEnv.makeChange(before, after)

    await wrapped(change)

    const issueDoc = await admin.firestore().doc(`issues/${testIssueId}`).get()

    expect(issueDoc?.data()?.upvotes).toBe(1)
    expect(issueDoc?.data()?.downvotes).toBeUndefined()
  })
})
