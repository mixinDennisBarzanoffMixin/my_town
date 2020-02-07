const { setup, teardown } = require('./helpers');

describe('Tests the issues rules', () => {
  const issueId = 'test-issue'
  const userId = 'test-user'
  const issuePath = `issues/${issueId}`
  const foreignIssuePath = `issues/foreign-issue`
  const userPath = `users/${userId}`;

  afterAll(async () => {
    await teardown();
  });

  test('Everyone should be able to see issues', async () => {
    const mockUser = undefined // not logged in
    const mockData = {
      [issuePath]: {
        uid: userId
      }
    }
    const db = await setup(mockUser, mockData);

    const ref = db.doc(issuePath)

    await expect(ref.get()).toBeAllowed(); // should fail
  });

  test('Only the creator should be able to write to their own issue', async () => {
    const foreignIssuePath = 'issues/another-issue'
    const mockUser = {
      uid: userId
    }
    const mockData = {
      [issuePath]: {
        ownerId: userId
      },
      [foreignIssuePath]: {
        ownerId: 'a-non-existent-user'
      }
    }
    const db = await setup(mockUser, mockData);

    const ownIssueRef = db.doc(issuePath)
    await expect(ownIssueRef.set({})).toBeAllowed();

    const foreignIssueRef = db.doc(foreignIssuePath);
    await expect(foreignIssueRef.set({})).toBeDenied();
  });


  test('Anyone should be able to create an issue, provided the ownerId is correct', async () => {
    var mockUser = {
      uid: userId
    };
    var mockData = {
    }
    const db = await setup(mockUser, mockData);

    const issueRef = db.doc(issuePath)
    await expect(issueRef.set({})).toBeDenied();

    await expect(issueRef.set({ ownerId: userId })).toBeAllowed();
  });
  test('Users should be able to delete their issues', async () => {
    var mockUser = {
      uid: userId
    };
    var mockData = {
      [issuePath]: {
        ownerId: userId
      }
    }
    const db = await setup(mockUser, mockData);

    const issueRef = db.doc(issuePath)
    await expect(issueRef.delete()).toBeAllowed();

    const foreignIssueRef = db.doc(foreignIssuePath);
    await expect(foreignIssueRef.delete()).toBeDenied();
  });

  test('Admins should be able to delete issues', async () => {
    var mockUser = {
      uid: userId
    };
    var mockData = {
      [userPath]: {
        roles: {
          admin: true
        }
      },
      [issuePath]: {
        ownerId: 'another-user'
      }
    }
    const db = await setup(mockUser, mockData);

    const issueRef = db.doc(issuePath)
    await expect(issueRef.delete()).toBeAllowed();
  });
});