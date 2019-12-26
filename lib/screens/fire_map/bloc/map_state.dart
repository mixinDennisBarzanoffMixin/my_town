import 'package:meta/meta.dart';
import 'package:my_town/shared/location.dart';

@immutable
abstract class MapState {}
  
class InitialMapState extends MapState {}

class RadiusAndLocationReadyMapState extends MapState {
  final RadiusAndLocation radiusAndLocation;

  RadiusAndLocationReadyMapState(this.radiusAndLocation);
}


class RadiusAndLocation {
  final double radius;
  final Location location;

  const RadiusAndLocation(this.radius, this.location);
}
