import 'package:cloud_firestore/cloud_firestore.dart';

class IssueFetched {
  String id;
  String details;
  String imageUrl;
  String thumbnailUrl;
  double distance;
  GeoPoint geopoint;

  IssueFetched(this.id, this.details, this.imageUrl, this.thumbnailUrl,
      this.distance, this.geopoint);

 IssueFetched.fromGeoFireDocument(DocumentSnapshot document)
     : this(
         document.documentID,
         document.data['details'],
         document.data['imageUrl'],
         document.data['thumbnailUrl'],
         document.data['distance'],
         document.data['position']['geopoint'],
       );

  get hasThumbnail => this.thumbnailUrl != null;
}
