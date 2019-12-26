import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_town/shared/location.dart';

class User {
  final String displayName;
  final Location homeLocation;
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
          Location.fromGeoPoint(document['homeLocation']),
          document['photoUrl'],
          document['providerId'],
          document['uid'],
        );
}
