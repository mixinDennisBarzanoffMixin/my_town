import { uuid } from "uuidv4"
import { admin, testEnv } from "./test.config"
import { WrappedFunction } from "firebase-functions-test/lib/main";
import { removeIssueImagesAfterDeleting } from "../src/issue_image";

const db = admin.firestore();
const bucket = admin.storage().bucket()

describe('Unused images are removed when the issue is deleted', () => {
    const issueId = uuid()
    const issueRef = db.doc(`issues/${issueId}`)
    let wrappedRemovesImages: WrappedFunction

    const imagePath = `issues/${issueId}.jpg`
    const thumbnailPath = `issues/thumbnails/${issueId}_180x180.jpg`

    beforeAll(async () => {
        wrappedRemovesImages = testEnv.wrap(removeIssueImagesAfterDeleting)
        const testImagePath = __dirname + '/assets/test_image.jpg'
        return Promise.all([
            bucket.upload(testImagePath, { destination: imagePath }),
            bucket.upload(testImagePath, { destination: thumbnailPath }),
        ])
    })

    test('deletes unused files after deleting issue', async () => {
        const snap = testEnv.firestore.makeDocumentSnapshot({}, issueRef.path)

        await wrappedRemovesImages(snap, { params: { issueId: issueId } })

        const [[imageExists], [thumbnailExists]] = await Promise.all([
            bucket.file(imagePath).exists(),
            bucket.file(thumbnailPath).exists(),
        ])
        expect(imageExists).toBe(false)
        expect(thumbnailExists).toBe(false)

    })

    afterAll(() => { // just in case
        return Promise.all([
            bucket.file(imagePath).delete(),
            bucket.file(thumbnailPath).delete(),
        ])
    })
})