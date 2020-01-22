import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);

  factory Location.fromLatLng(LatLng latlng) {
    return Location(latlng.latitude, latlng.longitude);
  }
  factory Location.fromPosition(Position position) {
    return Location(position.latitude, position.longitude);
  }
  factory Location.fromGeoPoint(GeoPoint geoPoint) {
    return Location(geoPoint.latitude, geoPoint.longitude);
  }

  LatLng toLatLng() => LatLng(this.latitude, this.longitude);
}
