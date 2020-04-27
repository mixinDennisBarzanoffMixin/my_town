import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from './helpers';

export const votesAggregate = functions.firestore.document('issue-votes/{issueVoteId}').onWrite(async (change, context) => {
    const afterData = change.after.data();
    const beforeData = change.before.data();
    const issueId = afterData?.issueId;

    const isUpvote = afterData?.upvote;
    const wasUpvote = beforeData?.upvote

    // possible states
    /* bef upvote, aft upvote

             -          true
             -          false
             
             true        -
             false       -
             
             true       false
             false      true
             
             true       true
             false      false

             -           -
    */

    const isVoteBeingAdded = beforeData?.upvote === undefined && afterData?.upvote !== undefined;
    const isVoteBeingRemoved = afterData?.upvote === undefined && beforeData?.upvote !== undefined;
    const isVoteChanged = beforeData?.upvote !== afterData?.upvote
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
    } else if (isVoteChanged) { // vote changed
        data.upvotes = isUpvote ? increment : decrement;
        data.downvotes = isUpvote ? decrement : increment;
    }

    return await issueRef.set(data, { merge: true });
})

async function deleteUserVotes(ref: (ref: admin.firestore.CollectionReference) => FirebaseFirestore.Query) {
    const batch = db.batch()
    const querySnapshot = await ref(db.collection('issue-votes')).get()
    querySnapshot.forEach((snap) => batch.delete(snap.ref)) // there may be multiple issue votes - it's many-to-many
    await batch.commit()
}

export const removeUserVotesAfterDeletingIssue = functions.firestore.document('issues/{issueId}').onDelete((snap, context) => {
    const issueId = context.params.issueId
    return deleteUserVotes(ref => ref.where('issueId', '==', issueId))
})

export const removeUserVotesAfterDeletingUser = functions.firestore.document('users/{userId}').onDelete((snap, context) => {
    const userId = context.params.userId
    return deleteUserVotes(ref => ref.where('userId', '==', userId))
})