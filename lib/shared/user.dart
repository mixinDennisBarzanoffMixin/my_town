import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String displayName;
  final GeoPoint homeLocation;
  final String photoUrl;
  final String providerId;
  final String uid;

  const User(
    this.displayName,
    this.homeLocation,
    this.photoUrl,
    this.providerId,
    this.uid,
  );

  User.fromDocument(DocumentSnapshot document)
      : this(
          document['displayName'],
          document['homeLocation'],
          document['photoUrl'],
          document['providerId'],
          document['uid'],
        );
}
