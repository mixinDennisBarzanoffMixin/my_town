import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_town/services/auth.dart';
import 'package:my_town/services/issues_db.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/location.dart';
import 'package:rxdart/rxdart.dart';

part 'issues_event.dart';
part 'issues_state.dart';

const _defaultRadius = 5.0;

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  IssuesDatabaseService _db = IssuesDatabaseService();
  Geolocator _locator = Geolocator();
  AuthService _auth = AuthService();

  @override
  IssuesState get initialState => InitialIssuesState();

  @override
  Stream<IssuesState> mapEventToState(IssuesEvent event) async* {
    yield IssuesLoadingState();
    if (event is GetIssuesWithinMapBoundsEvent) {
      final area = await _mapScreenDataToArea(event.mapData);
      yield* getIssuesLoadedStatesStream(
        area.radius,
        area.location,
        (issues) => IssuesLoadedState(issues: issues),
      );
    } else if (event is GetIssuesAtCurrentLocation) {
      final location = await this
          ._locator
          .getCurrentPosition()
          .then((position) => Location.fromPosition(position));
      // Circle circle = Circle(
      //   center: location.toLatLng(),
      //   radius: _defaultRadius * 1000,
      //   circleId: CircleId('circle'),
      // );
      // print('bloc processing current location');
      // final zoom = getZoomLevel(circle);
      // print(zoom);
      yield* getIssuesLoadedStatesStream(
        _defaultRadius,
        location,
        (issues) =>
            IssuesLoadedAtLocationState(issues: issues, location: location),
      );
    } else if (event is GetIssuesAtHomeLocation) {
      final user = await _auth.getUser;
      final location = user.homeLocation;
      // Circle circle = Circle(
      //   center: location.toLatLng(),
      //   radius: _defaultRadius,
      //   circleId: CircleId('circle'),
      // );
      // print('bloc processing current location');
      // final zoom = getZoomLevel(circle);
      yield* getIssuesLoadedStatesStream(
        _defaultRadius,
        location,
        (issues) =>
            IssuesLoadedAtLocationState(issues: issues, location: location),
      );
    }
  }

  /// `events` is the event subject
  /// [mapEventToState] is passed as `next` by the library
  @override
  Stream<Transition<IssuesEvent, IssuesState>> transformEvents(events, next) {
    // The stream never ends so the default asyncMap doesn't work,
    // we need to switch to the new Stream values when they appear
    return events
        .debounceTime(
          // the user has to let the map go for 150ms
          Duration(milliseconds: 150),
        )
        .switchMap(next);
  }


  @override
  Stream<Transition<IssuesEvent, IssuesState>> transformTransitions(Stream<Transition<IssuesEvent, IssuesState>> transitions) {
    // we only need the latest event, not all of them
    return transitions.shareReplay(maxSize: 1);
  }

  Stream<IssuesLoadedState> getIssuesLoadedStatesStream(double radius,
          Location location, IssuesState Function(List<IssueFetched>) map) =>
      _db.getIssues(radius, location).map(map);

  Future<double> _getMapVisibleRadius(LatLngBounds visibleRegion) async {
    var screenDiameterInMeters = await _locator.distanceBetween(
      visibleRegion.southwest.latitude,
      visibleRegion.southwest.longitude,
      visibleRegion.northeast.latitude,
      visibleRegion.northeast.longitude,
    );

    var screenDiameterInKilometers = screenDiameterInMeters / 1000;

    return screenDiameterInKilometers / 2; // r = d / 2
  }

  Future<Area> _mapScreenDataToArea(
    MapScreenData mapScreenData,
  ) async {
    // todo here we need only a location and a radius
    var visibleRegionBounds = mapScreenData.bounds;

    var radius = await _getMapVisibleRadius(visibleRegionBounds);
    print(radius);
    var location = mapScreenData.position.target;

    return Area(radius, Location.fromLatLng(location));
  }
}

class Area {
  final double radius;
  final Location location;

  const Area(this.radius, this.location);
}

/// @param circle : circle 
/// @return : return zoom level according to circle radius
// double getZoomLevel(Circle circle) {
//   int zoomLevel = 11;
//   if (circle != null) {
//     double radius = circle.radius + circle.radius / 2;
//     double scale = radius / 500;
//     zoomLevel = (16 - log(scale) / log(2)) as int;
//   }
//   return zoomLevel + .4;
// }
