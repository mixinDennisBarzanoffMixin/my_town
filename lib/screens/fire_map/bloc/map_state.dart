import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MapState {}
  
class InitialMapState extends MapState {}

class RadiusAndLocationReadyMapState extends MapState {
  final RadiusAndLocation radiusAndLocation;

  RadiusAndLocationReadyMapState(this.radiusAndLocation);
}


class RadiusAndLocation {
  final double radius;
  final LatLng location;

  const RadiusAndLocation(this.radius, this.location);
}
