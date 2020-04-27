import 'jest'
import { testEnv, admin, firebase } from './test.config'

import { mapCategoryToInstitution } from '../src/mapping'
import { uuid } from 'uuidv4'
import { WrappedFunction } from 'firebase-functions-test/lib/main'

describe('Issue mappings are working properly', () => {
    const issueId = uuid()
    const db = admin.firestore()

    // const issueRef = db.doc(`issues/${issueId}`)

    const mappingId = issueId;
    const mappingRef = db.doc(`issue_mapping/${mappingId}`)

    let wrappedMapIssue: WrappedFunction

    beforeAll(async () => {
        wrappedMapIssue = testEnv.wrap(mapCategoryToInstitution)
    })

    test('Maps to the correct institutions', async () => {
        const geopoint = new firebase.firestore.GeoPoint(42.6627513, 23.3734728)
        console.log(geopoint)
        const snap = testEnv.firestore.makeDocumentSnapshot({
            category: 'brokenStreetLamp', // TODO: add to frontend
            position: {
                geopoint: { // have to pass the data like this cuz "local" firebase doesn't support GeoPoints
                    latitude: geopoint.latitude,
                    longitude: geopoint.longitude
                }
            }
        }, mappingRef.path)
        const change = testEnv.makeChange(undefined, snap)
        await wrappedMapIssue(change, { params: { issueId } })

        const mappingDoc = await mappingRef.get()
        const {institutionType, institution} = mappingDoc.data()!!;
        expect(institutionType).toEqual("municipality")
        expect(institution.name).toEqual("Mladost District of Sofia")        
    })
})
