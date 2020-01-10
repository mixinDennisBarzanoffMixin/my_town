import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:my_town/shared/location.dart';

class IssueFetched extends Equatable {
  final String id;
  final String details;
  final String imageUrl;
  final String thumbnailUrl;
  final double distance;
  final Location location;
  final int upvotes;
  final int downvotes;

  const IssueFetched(this.id, this.details, this.imageUrl, this.thumbnailUrl,
      this.distance, this.location, this.upvotes, this.downvotes);

  IssueFetched.fromGeoFireDocument(DocumentSnapshot document)
      : this(
          document.documentID,
          document.data['details'],
          document.data['imageUrl'],
          document.data['thumbnailUrl'],
          document.data['distance'],
          Location.fromGeoPoint(document.data['position']['geopoint']),
          document.data['upvotes'],
          document.data['downvotes'],
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

class IssueFetchedWithBytes extends IssueFetched {
  final Uint8List imageBytes;
  const IssueFetchedWithBytes(
    String id,
    String details,
    String imageUrl,
    String thumbnailUrl,
    double distance,
    Location location,
    int upvotes,
    int downvotes,
    this.imageBytes,
  ) : super(id, details, imageUrl, thumbnailUrl, distance, location, upvotes,
            downvotes);

  IssueFetchedWithBytes.fromIssueFetched(
      IssueFetched issueFetched, Uint8List imageBytes)
      :this(
          issueFetched.id,
          issueFetched.details,
          issueFetched.imageUrl,
          issueFetched.thumbnailUrl,
          issueFetched.distance,
          issueFetched.location,
          issueFetched.upvotes,
          issueFetched.downvotes,
          imageBytes,
        );
}
