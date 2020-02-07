const { setup, teardown } = require('./helpers');

describe('Tests the issue-votes rules', () => {
    const userId = 'test-user'
    const userPath = `users/${userId}`

    const issueId = 'test-issue'
    const issuePath = `issues/${issueId}`

    const voteId = `${userId}_${issueId}`
    const votePath = `issue-votes/${voteId}`


    afterAll(async () => {
        await teardown();
    });

    test('Everyone should be able to see issue-vote rules', async () => {
        const mockUser = undefined;
        const mockData = {
            [issuePath]: {
                uid: userId
            },
            [votePath]: {
                userId,
                issueId,
                upvote: true
            }
        }
        const db = await setup(mockUser, mockData);

        const voteRef = db.doc(votePath)

        await expect(voteRef.get()).toBeAllowed();
    });

    test('Only the owner should be able to change their own vote', async () => {
        const mockUser = {
            uid: userId
        };
        const foreignVote = {
            userId: 'foreign-user',
            issueId,
            upvote: true
        }
        const foreignVotePath = `issue-votes/${foreignVote.userId}_${foreignVote.issueId}`
        const mockData = {
            [issuePath]: {
                uid: userId
            },
            [votePath]: {
                userId,
                issueId,
                upvote: true
            },
            [foreignVotePath]: foreignVote
        }
        const db = await setup(mockUser, mockData);

        const voteRef = db.doc(votePath);
        await expect(voteRef.get()).toBeAllowed();

        const foreignVoteRef = db.doc(foreignVotePath);
        await expect(foreignVoteRef.set({})).toBeDenied();
    });

    test('Creating a vote must be with valid data', async () => {
        const mockUser = {
            uid: userId
        };
        const mockData = {}
        const db = await setup(mockUser, mockData);

        const voteRef = db.doc(votePath)

        await expect(voteRef.set({})).toBeDenied();
        await expect(voteRef.set({ userId })).toBeAllowed();
    });
});