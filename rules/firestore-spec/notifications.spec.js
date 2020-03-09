const { setup, teardown } = require('./helpers');

describe('Tests the user rules', () => {
    const userId = 'test-user-id'
    const userPath = `users/${userId}`
    const tokenPath = `${userPath}/tokens/test-token-id`
    afterAll(async () => {
        await teardown();
    });

    test('Users should be able to read and write tokens', async () => {
        const mockUser = {uid: userId};
        const mockData = {
            [userPath]: {

            }
        }
        const db = await setup(mockUser, mockData);

        const tokenRef = db.doc(tokenPath)

        await expect(tokenRef.get()).toBeAllowed();
        await expect(tokenRef.set({token: 'hello'})).toBeAllowed();
    });

    test('Other users shouldn\'t be able to write tokens', async () => {
        const mockUser = {uid: 'other-user'};
        const mockData = {}
        const db = await setup(mockUser, mockData);

        const tokenRef = db.doc(tokenPath)

        await expect(tokenRef.get()).toBeDenied();
        await expect(tokenRef.set({token: 'hello'})).toBeDenied();
    });
});