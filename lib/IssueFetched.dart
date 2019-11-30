import 'package:cloud_firestore/cloud_firestore.dart';

// class IssuePosition {
//   GeoPoint geopoint;

//   IssuePosition.fromMap(Map<dynamic, dynamic> data) {
//     this.geopoint = data['position'];
//   }
// }

class IssueFetched {
  String id;
  String details;
  String imageUrl;
  String thumbnailUrl;
  double distance;
  GeoPoint geopoint;

  IssueFetched(this.id, this.details, this.imageUrl, this.thumbnailUrl,
      this.distance, this.geopoint);

//  IssueFetched.fromMap(Map<String, dynamic> data) : this(d;

 IssueFetched.fromDocument(DocumentSnapshot document)
     : this(
         document.documentID,
         document.data['details'],
         document.data['imageUrl'],
         document.data['thumbnailUrl'],
         document.data['distance'],
         document.data['position']['geopoint'],
       );

  // IssueFetched.fromDocument(DocumentSnapshot document) {
  //   print('mapping');
  //   this.id = document.documentID;
  //   this.details = document.data['details'];
  //   this.imageUrl = document.data['imageUrl'];
  //   this.thumbnailUrl = document.data['thumbnailUrl'];
  //   this.distance = document.data['distance'];
  //   this.geopoint = document.data['position']['geopoint'];
  
  // }

//details = data['details'],
//        imageUrl = data['imageUrl'],
//        thumbnailUrl = data['thumbnailUrl'],
//        position = IssuePosition.fromMap(data['position']);
}
