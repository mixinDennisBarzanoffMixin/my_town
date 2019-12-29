import 'jest'
import { admin, testEnv } from './test.config'
import { uuid } from 'uuidv4'
import { removeUserVotesAfterDeletingIssue, removeUserVotesAfterDeletingUser } from '../src/votes';

describe('User votes are deleted when issue or user is deleted', () => {
    const wrappedRemoveUserVotesAfterDeletingIssue = testEnv.wrap(removeUserVotesAfterDeletingIssue)
    const wrappedRemoveUserVotesAfterDeletingUser = testEnv.wrap(removeUserVotesAfterDeletingUser)
    const issueId = uuid()
    const userId = uuid()
    const db = admin.firestore()
    const issueRef = db.doc(`issues/${issueId}`)
    const userRef = db.doc(`users/${userId}`)
    const userVoteRef = db.doc(`user-votes/${issueId}_${userId}`)

    beforeEach(async () => {
        await issueRef.set({})
        await userRef.set({})
        await userVoteRef.set({
            issueId,
            userId,
            upvote: true,
        })
    })

    test('deletes votes after deleting issue', async () => {
        await issueRef.delete()
        const snap = testEnv.firestore.makeDocumentSnapshot({}, issueRef.path)
        await wrappedRemoveUserVotesAfterDeletingIssue(snap, { params: { issueId } })
        const voteSnap = await userVoteRef.get()
        expect(voteSnap.exists).toBe(false)
    })

    test('deletes votes after deleting user', async () => {
        await userRef.delete()
        const snap = testEnv.firestore.makeDocumentSnapshot({}, userRef.path)
        await wrappedRemoveUserVotesAfterDeletingUser(snap, { params: { userId } })
        const voteSnap = await userVoteRef.get()
        expect(voteSnap.exists).toBe(false)
    })

    afterEach(() => {
        return Promise.all([
            issueRef.delete(),
            userRef.delete(),
            userVoteRef.delete(),
        ])
    })
}) // todo test if condition in issue images


