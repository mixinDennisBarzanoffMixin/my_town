import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_town/screens/fire_map/bloc/bloc.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/progress_indicator.dart';

class FireMap extends StatefulWidget {
  const FireMap({
    Key key,
  }) : super(key: key);

  @override
  _FireMapState createState() => _FireMapState();
}

class _FireMapState extends State<FireMap> {
  GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    final LatLng initialLocation = ModalRoute.of(context).settings.arguments;

    return BlocProvider<MapBloc>(
      create: (context) => MapBloc(),
      child: BlocListener<MapBloc, MapState>(
        listener: (context, state) {
          if (state is RadiusAndLocationReadyMapState) {
            print('new things radius');
            var radiusAndLocation = state.radiusAndLocation;
            BlocProvider.of<IssuesBloc>(context).add(
              GetIssuesAtLocationWithRadiusEvent(
                radiusAndLocation.radius,
                radiusAndLocation.location.toPosition(),
              ),
            );
          }
        },
        child: BlocBuilder<IssuesBloc, IssuesState>(
          builder: (context, state) {
            print('rebuilt');
            Set<Marker> markers = {};
            if (state is IssuesLoadedState) {
              markers = state.issues.map((issues) => issues.toMarker()).toSet();
            }
            var initialCameraPosition = CameraPosition(
              target: initialLocation,
              zoom: 10,
            );

            return GoogleMap(
              initialCameraPosition: initialCameraPosition,
              mapType: MapType.normal,
              onCameraMove: (CameraPosition cameraPosition) async {
                // add item to bloc for the rest of the UI to react properly
                BlocProvider.of<MapBloc>(context).add(
                  MapNewVisibleRegionEvent(
                    MapScreenData(
                      await _mapController.getVisibleRegion(),
                      cameraPosition,
                    ),
                  ),
                );
              },
              onMapCreated: (mapController) async {
                print('map created');
                this._mapController = mapController;
                BlocProvider.of<MapBloc>(context).add(
                  MapNewVisibleRegionEvent(
                    MapScreenData(
                      await _mapController.getVisibleRegion(),
                      initialCameraPosition,
                    ),
                  ),
                );
              },
              // no maximum zoom
              minMaxZoomPreference: MinMaxZoomPreference(null, null),
              // data will be null in waiting state
              //todo make the list of markers a set
              markers: markers,
            );
          },
        ),
      ),
    );
  }
}

extension on IssueFetched {
  Marker toMarker() {
    GeoPoint pos = this.geopoint;
    double distance = this.distance;

    // document id is the id of the marker since markers represent individual documents
    var markerId = MarkerId(this.id);
    return Marker(
      markerId: markerId,
      position: LatLng(pos.latitude, pos.longitude),
      // TODO: make use of anchor (custom dot that connects the icon to the location)
      infoWindow: InfoWindow(
        title: 'Magic Marker',
        snippet: '$distance km from query center',
      ),
    );
  }
}

extension on LatLng {
  toPosition() {
    return Position(latitude: this.latitude, longitude: this.longitude);
  }
}
