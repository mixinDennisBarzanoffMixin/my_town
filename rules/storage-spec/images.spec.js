const { RuleTestSuite, validateRuleSuite } = require('firebase-security-testing');
 
// Initialise the rule test suite
var storageRules = new RuleTestSuite({
    rulePath: __dirname + '/../../storage.rules', 
    project: 'my-town-ba556', 
    description: 'storage rules'
});

const defaultBucket = 'my-town-ba556.appspot.com';

storageRules.test('Everyone should be able to read the images', {
    path: `/b/${defaultBucket}/o/issueId/image.jpg`,
    method: 'get',
}).shouldSucceed();

storageRules.test('Everyone should be able to read the thumbnail', {
    path: `/b/${defaultBucket}/o/issueId/image_180x180.jpg`,
    method: 'get',
}).shouldSucceed();

storageRules.test('Another user shouldn\'t be able to update user\'s images', {
    path: `/b/${defaultBucket}/o/issueId/image.jpg`,
    method: 'create',
    auth: {
        uid: 'anotherUserId'
    },
    resource: {
        metadata: {
            uid: 'fakeUid'
        }
    }
}).shouldFail();
 
storageRules.test('Only the owner should be able to write to their own image', {
    path: `/b/${defaultBucket}/o/issueId/image.jpg`,
    method: 'create',
    auth: {
        uid: 'userId'
    },
    resource: {
        metadata: {
            uid: 'userId'
        }
    }
}).shouldSucceed();

validateRuleSuite(storageRules, { logging: true });