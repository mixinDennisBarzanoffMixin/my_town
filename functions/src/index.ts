import * as admin from 'firebase-admin'

admin.initializeApp()

export { addGeneratedThumbnailToDocument, removeIssueImagesAfterDeleting } from './issue_image';
export { votesAggregate } from './votes';