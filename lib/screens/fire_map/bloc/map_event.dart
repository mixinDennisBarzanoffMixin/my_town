import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MapEvent {}

class MapNewVisibleRegionEvent extends MapEvent {
  final MapScreenData mapData;

  MapNewVisibleRegionEvent(this.mapData);
}



class MapScreenData {
  // used as a tuple (like a Kotlin data class)
  final LatLngBounds bounds;
  final CameraPosition position;

  const MapScreenData(this.bounds, this.position);
}