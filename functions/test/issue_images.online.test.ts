import 'jest'
import { admin, testEnv } from './test.config'
import { addGeneratedThumbnailToDocument } from '../src/issue_image'
import * as fs from 'fs';
import { uuid } from 'uuidv4'
import fetch from 'node-fetch'

describe('Tests the issue image cloud functions', () => {
    let wrappedAddGeneratedThumbnail: any
    const issueId = uuid()
    const bucket = admin.storage().bucket()
    const db = admin.firestore();
    const issueRef = db.doc(`issues/${issueId}`)

    const thumbnailFilename = `${issueId}/image_180x180.jpg`
    const imageFilename = `${issueId}/image.jpg`

    beforeEach(async () => {
        await issueRef.set({})
        wrappedAddGeneratedThumbnail = testEnv.wrap(addGeneratedThumbnailToDocument)
        await bucket.upload(__dirname + '/assets/test_image.jpg', { destination: thumbnailFilename })
        await bucket.upload(__dirname + '/assets/test_image.jpg', { destination: imageFilename })
    })

    test('adds generated thumbnail to document', async () => {
        const objectMetadata = testEnv.storage.makeObjectMetadata({ name: thumbnailFilename })
        await wrappedAddGeneratedThumbnail(objectMetadata)
        const issueDoc = await issueRef.get()
        expect(issueDoc?.data()?.thumbnailUrl).toBeDefined()
        const thumbnailResponse = await fetch(issueDoc?.data()?.thumbnailUrl)
        const resultArrayBuffer = await thumbnailResponse.arrayBuffer()
        const resultImageData = Buffer.from(resultArrayBuffer)
        const expectedImageData = fs.readFileSync(__dirname + `/assets/test_image.jpg`)
        const comparison = Buffer.compare(resultImageData, expectedImageData)
        expect(comparison).toBe(0)
    })

    test('doesn\'t add a non thumbnail image to issue', async () => {
        let issueDoc = await issueRef.get()
        expect(issueDoc?.data()?.thumbnailUrl).toBeUndefined()
        const objectMetadata = testEnv.storage.makeObjectMetadata({ name: imageFilename })
        await wrappedAddGeneratedThumbnail(objectMetadata)
        issueDoc = await issueRef.get()
        expect(issueDoc?.data()?.thumbnailUrl).toBeUndefined()
    })

    afterAll(() => {
        return Promise.all([
            bucket.file(imageFilename).delete(),
            bucket.file(thumbnailFilename).delete(),
            issueRef.delete(),
        ])
    })
}) // todo test if condition in issue images