import * as functions from 'firebase-functions';
import { uuid as Uuid } from 'uuidv4'

import * as admin from 'firebase-admin'
import { basename } from 'path'

admin.initializeApp()

var defaultStorage = admin.storage()
var db = admin.firestore()

exports.removeProfilePictureWhenDeletingUserData = functions.firestore
  .document('issues/{issueId}')
  .onDelete((snap, context) => {
    const issueId = context.params.issueId

    const bucket = defaultStorage.bucket()
    const image = bucket.file(`issues/${issueId}.jpg`)
    const thumbnail = bucket.file(`issues/thumbnails/${issueId}_180x180.jpg`)

    // Delete the file
    return Promise.all([image.delete(), thumbnail.delete()])
  })

exports.addGeneratedThumbnailToDocument = functions.storage
  .object()
  .onFinalize(async (file) => { // todo scope them to buckets
    const bucket = defaultStorage.bucket();
    if (file.name && /issues\/thumbnails\/.*/.test(file.name)) { // apply only to thumbnails
      console.log(file.name)
      // Note if file gets uploaded from here -> infinite recursion!
      
      
      // issues/thumbnails/ issueId_180x180.jpg -> 
      // ['issues/thumbnails/ issueId_180x180.jpg', ' issueId']
      // we need to remove the magical space in front of the issueId
      const issueId = /(.*)_180x180.jpg/.exec(basename(file.name))![1].trim() // second is the match
      console.log(issueId)
      const token = Uuid();
      const metadata = { // double nesting necessary
        metadata: {
          firebaseStorageDownloadTokens: token
        }
      }
      // The other way is to call makePublic() and 
      // then construct the url from storage.googleapis.com/bucket/file.jpg
      // Tokens are safer
      const [newMetadata] = await bucket.file(file.name).setMetadata(metadata)
      console.log(newMetadata)
      const issueRef = db.doc(`issues/${issueId}`)
      const thumbnailUrl = `https://firebasestorage.googleapis.com/v0/b/my-site-c41d6.appspot.com/o/${encodeURIComponent(file.name)}?alt=media&token=${token}`
      await issueRef.set({ thumbnailUrl }, { merge: true })
      // add the thumbnail non-destructively
    }
  })