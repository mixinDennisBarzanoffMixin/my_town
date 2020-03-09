import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

const db = admin.firestore()
const fcm = admin.messaging();

const FieldValue = admin.firestore.FieldValue;

export const increaseIssuesCount = functions.firestore
    .document('issues/{issueId}')
    .onDelete(async (snapshot, context) => {
        const ownerId = snapshot.data()!.ownerId;
        return db.doc(`users/${ownerId}`).set({ issueCount: FieldValue.increment(-1) }, { merge: true })
    })

export const notifyAboutFirstReportAndIncreaseIssuesCount = functions.firestore
    .document('issues/{issueId}')
    .onCreate(async snapshot => { // TODO: test
        const issue = snapshot.data();
        const ownerId = issue!.ownerId
        const ownerRef = db.doc(`users/${ownerId}`)

        const owner = await ownerRef.get()

        console.log(owner.data()!.issueCount)

        if (owner.data()?.issueCount === 0) {// first issue
            const querySnapshot = await db
                .collection('users')
                .doc(ownerId)
                .collection('tokens')
                .get();

            const tokens = querySnapshot.docs.map(snap => snap.id);

            const payload: admin.messaging.MessagingPayload = {
                notification: {
                    title: 'Achievement Made',
                    body: `You got an achievement for reporting your first issue`,
                    icon: 'your-icon-url', // TODO: add a proper icon
                    click_action: 'FLUTTER_NOTIFICATION_CLICK'
                }, 
                data: {
                    achievement: 'reporter'
                }
            };

            await fcm.sendToDevice(tokens, payload)
        }
        return ownerRef.set({ issueCount: FieldValue.increment(1) }, { merge: true })
    })