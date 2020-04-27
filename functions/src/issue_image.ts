import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin'

import { uuid } from 'uuidv4'
import { bucket, db } from './helpers';

// todo rename function
export const removeIssueImagesAfterDeleting = functions.firestore
  .document('issues/{issueId}')
  .onDelete((snap, context) => {
    const issueId = context.params.issueId

    const image = bucket.file(`${issueId}/image.jpg`)
    const thumbnail = bucket.file(`${issueId}/image_180x180.jpg`)
    // Delete the file
    return Promise.all([image.delete(), thumbnail.delete()])
  })

export const addGeneratedThumbnailToDocument = functions.storage
  .object()
  .onFinalize(async (file) => { // todo scope them to buckets
    if (file.name && /image_180x180.jpg/.test(file.name)) { // apply only to thumbnails
      // console.log(file.name)
      // Note if file gets uploaded from here -> infinite recursion!

      // issues/thumbnails/issueId_180x180.jpg -> 
      // ['issues/thumbnails/issueId_180x180.jpg', ' issueId']
      const issueId = /(.*)\/image_180x180.jpg/.exec(file.name)![1] // second is the match
      // console.log(issueId)
      const token = uuid()
      const metadata = { // double nesting necessary
        metadata: {
          firebaseStorageDownloadTokens: token
        }
      }
      // The other way is to call makePublic() and 
      // then construct the url from storage.googleapis.com/bucket/file.jpg
      // Tokens are safer
      await bucket.file(file.name).setMetadata(metadata)
      // const [newMetadata] = await bucket.file(file.name).setMetadata(metadata)
      // console.log(newMetadata)
      const issueRef = db.doc(`issues/${issueId}`)
      const projectId = admin.instanceId().app.options.projectId
      console.log(projectId)

      const thumbnailUrl = `https://firebasestorage.googleapis.com/v0/b/${projectId}.appspot.com/o/${encodeURIComponent(file.name)}?alt=media&token=${token}`
      return await issueRef.set({ thumbnailUrl }, { merge: true })
      // add the thumbnail non-destructively
    }
    return // do nothing
  })