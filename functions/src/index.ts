import * as admin from 'firebase-admin'

admin.initializeApp({
    storageBucket: "my-town-ba556.appspot.com",
    databaseURL: "https://my-town-ba556.firebaseio.com",
    projectId: "my-town-ba556",
})

export { addGeneratedThumbnailToDocument, removeIssueImagesAfterDeleting } from './issue_image';
export { votesAggregate, removeUserVotesAfterDeletingUser, removeUserVotesAfterDeletingIssue } from './votes';