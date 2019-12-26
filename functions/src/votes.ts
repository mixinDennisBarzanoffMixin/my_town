import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const votesAggregate = functions.firestore.document('issue-votes/{issueVoteId}').onWrite((change, context) => {
    const afterData = change.after.data();
    const beforeData = change.before.data();
    const issueId = afterData?.issueId;

    const isUpvote = afterData?.upvote;
    const wasUpvote = beforeData?.upvote

    const isVoteBeingAdded = beforeData?.upvote === undefined && afterData?.upvote !== undefined;
    const isVoteBeingRemoved = afterData?.upvote === undefined && beforeData?.upvote !== undefined;

    const FieldValue = admin.firestore.FieldValue;

    const increment = FieldValue.increment(1);
    const decrement = FieldValue.increment(-1);

    const issueRef = db.doc(`issues/${issueId}`);

    const data: any = {};
    if (isVoteBeingAdded) {
        if (isUpvote) {
            data.upvotes = increment;
        } else {
            data.downvotes = increment;
        }
    } else if (isVoteBeingRemoved) {
        if (wasUpvote) {
            data.upvotes = decrement;
        } else { // was downvote
            data.downvotes = decrement;
        }
    } else { // vote changed
        data.upvotes = isUpvote ? increment : decrement;
        data.downvotes = isUpvote ? decrement : increment;
    }

    return issueRef.set(data, { merge: true });
});