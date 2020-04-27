const { setup, teardown } = require('./helpers');

describe('Tests the mapping rules', () => {
    const issueId = `test-issue-id`
    const mappingPath = `issue_mapping/${issueId}`

    afterAll(async () => {
        await teardown();
    });

    test('Everyone should be able to see where a signal was sent, but nobody should be albe to write it', async () => {
        const mockUser = undefined; // not logged in
        const mockData = undefined;
        const db = await setup(mockUser, mockData);

        const ref = db.doc(mappingPath)

        await expect(ref.get()).toBeAllowed(); // should fail
        await expect(ref.set({})).toBeDenied(); // should fail
    });

    test('Nobody should be albe to write mappings, even logged in users', async () => {
        const mockUser = { uid: 'test-user' } // logged in
        const mockData = undefined;
        const db = await setup(mockUser, mockData);

        const ref = db.doc(mappingPath)

        await expect(ref.get()).toBeAllowed(); // should fail
        await expect(ref.set({})).toBeDenied(); // should fail
    });
});