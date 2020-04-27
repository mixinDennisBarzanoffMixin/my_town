import admin = require("firebase-admin");

export const defaultStorage = admin.storage()
export const bucket = defaultStorage.bucket()
export const db = admin.firestore()
export const fcm = admin.messaging();
export const FieldValue = admin.firestore.FieldValue;
