import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class IssueFetched extends Equatable {
  final String id;
  final String details;
  final String imageUrl;
  final String thumbnailUrl;
  final double distance;
  final GeoPoint geopoint;

  const IssueFetched(this.id, this.details, this.imageUrl, this.thumbnailUrl,
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

  @override
  String toString() {
    return """
      thumbnail: $thumbnailUrl,
      imageUrl: $imageUrl,
      details: $details,
    """;
  }

  @override
  List<Object> get props => [id];
}
