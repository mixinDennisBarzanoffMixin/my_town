part of 'issues_bloc.dart';

abstract class IssuesEvent {
  const IssuesEvent();
}

class GetIssuesWithinMapBoundsEvent extends IssuesEvent {
  final MapScreenData mapData;

  const GetIssuesWithinMapBoundsEvent(this.mapData);
}

class GetIssuesAtCurrentLocation extends IssuesEvent {}

class GetIssuesAtHomeLocation extends IssuesEvent {}



class MapScreenData {
  // used as a tuple (like a Kotlin data class)
  final LatLngBounds bounds;
  final CameraPosition position;

  const MapScreenData(this.bounds, this.position);
}
