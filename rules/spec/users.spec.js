const { setup, teardown } = require('./helpers');

describe('Tests the user rules', () => {
    const userId = 'test-user-id'
    const userPath = `users/${userId}`
    afterAll(async () => {
        await teardown();
    });

    test('Everyone should be able to see everybody else\'s public data', async () => {
        const mockUser = undefined;
        const mockData = {
            [userPath]: {}
        }
        const db = await setup(mockUser, mockData);

        const userRef = db.doc(userPath)

        await expect(userRef.get()).toBeAllowed();
    });

    test('Only the owner must be able to write to their own data', async () => {
        const mockUser = {
            uid: userId
        };
        const foreignUserPath = 'users/another-user'
        const mockData = {
            [foreignUserPath]: {}
        }
        const db = await setup(mockUser, mockData);

        const userRef = db.doc(foreignUserPath)

        await expect(userRef.set({})).toBeDenied();
    });

    test('Signed out users shouldn\'t be able to create user docs', async () => {
        const mockUser = undefined;
        const mockData = {}
        const db = await setup(mockUser, mockData);

        const userRef = db.doc(userPath)

        await expect(userRef.set({})).toBeDenied();
    });


    test('Signed in users should be able to create user docs with their id', async () => {
        const mockUser = {
            uid: userId
        };
        const mockData = {}
        const db = await setup(mockUser, mockData);

        const userRef = db.doc(userPath)

        await expect(userRef.set({})).toBeAllowed();
    });
});