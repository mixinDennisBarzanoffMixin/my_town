import * as admin from 'firebase-admin'

admin.initializeApp({
    storageBucket: "my-town-ba556.appspot.com"
})

export { addGeneratedThumbnailToDocument, removeIssueImagesAfterDeleting } from './issue_image';
export { votesAggregate, removeUserVotesAfterDeletingUser, removeUserVotesAfterDeletingIssue } from './votes';