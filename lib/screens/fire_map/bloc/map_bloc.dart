import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_town/shared/location.dart';
import 'package:rxdart/rxdart.dart';
import './bloc.dart';
import 'dart:math';

class MapBloc extends Bloc<MapEvent, MapState> {
  Geolocator _locator = Geolocator();
  @override
  MapState get initialState => InitialMapState();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is MapNewVisibleRegionEvent) {
      var radiusAndLocation =
          await _mapScreenDataToRadiusAndLocation(event.mapData);
      yield RadiusAndLocationReadyMapState(radiusAndLocation);
    }
  }

  @override
  Stream<MapState> transformEvents(events, next) {
    return super.transformEvents(
      Observable<MapEvent>(events).debounceTime(
        Duration(milliseconds: 150),
      ),
      next,
    );
  }

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

  Future<RadiusAndLocation> _mapScreenDataToRadiusAndLocation(
      MapScreenData mapScreenData) async {
    // todo here we need only a location and a radius
    var visibleRegionBounds = mapScreenData.bounds;

    var radius = await _getMapVisibleRadius(visibleRegionBounds);
    print(radius);
    var location = mapScreenData.position.target;

    return RadiusAndLocation(radius, Location.fromLatLng(location));
  }
}
