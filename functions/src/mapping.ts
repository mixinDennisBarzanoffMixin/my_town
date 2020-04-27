import * as functions from 'firebase-functions';
import mappings from './categories.mappings.json';
import institution_location_mappings from './institution_location_mappings.json'
import { db } from './helpers';
import { kdTree } from 'kd-tree-javascript'
import admin from 'firebase-admin';
// import admin from 'firebase-admin';

declare module Institution_Mappings {

    export interface Location {
        lat: number;
        lng: number;
    }

    export interface Municipality {
        name: string;
        location: Location;
        phoneNumber?: string;
    }

    export interface RootObject {
        municipality: Municipality[];
    }
}

var locations = institution_location_mappings.municipality.map((mun) => mun.location);
function distance(a: Institution_Mappings.Location, b: Institution_Mappings.Location) {
    return Math.pow(a.lat - b.lat, 2) + Math.pow(a.lng - b.lng, 2)
}
var tree = new kdTree(locations, distance, ["lat", "lng"])


export const mapCategoryToInstitution = functions.firestore
    .document('issues/{issueId}') // TODO: write to issue_mapping
    .onWrite(async (change, context) => {
        const issue = change.after
        const data = change.after.data()!!
        const category = data.category
        const institution = mappings.find(
            (institution) => institution.causes.includes(category)
        )
        const issueLocation: admin.firestore.GeoPoint = data.position.geopoint;


        const nearestInstitutionLocation = tree.nearest({ lat: issueLocation.latitude, lng: issueLocation.longitude }, 1)[0][0]
        const nearestInstitution = getInstitutionObjectByLocation(nearestInstitutionLocation)
        const mappingData = {
            institutionType: institution?.name,
            institution: nearestInstitution,
        }
        await db.doc(`issue_mapping/${issue.id}`).set(mappingData)
    })

function getInstitutionObjectByLocation(location: { "lat": number, "lng": number }) {
    return institution_location_mappings.municipality.find((mapping) => mapping.location == location)
}
