import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/location.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:my_town/shared/user.dart';
import 'package:provider/provider.dart';

class FireMap extends StatefulWidget {
  const FireMap({
    Key key,
  }) : super(key: key);

  @override
  _FireMapState createState() => _FireMapState();
}

class _FireMapState extends State<FireMap> {
  GoogleMapController _mapController;
  Future<Location> _initialLocation;
  Geolocator _locator = Geolocator();

  @override
  void initState() {
    super.initState();
    final homeLocation = Provider.of<User>(context, listen: false).homeLocation;
    _initialLocation = homeLocation != null
        ? Future.value(homeLocation)
        : _locator.getCurrentPosition(); // TODO: move logic elsewhere
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IssuesBloc, IssuesState>(
      condition: (oldState, newState) =>
          newState is IssuesLoadedAtLocationState,
      listener: (context, state) {
        // if (state is IssuesLoadedAtLocationState) {
        final locationIssueState = state as IssuesLoadedAtLocationState;
        print('updating camera');
        print(locationIssueState.location);

        final locations =
            locationIssueState.issues.map((issue) => issue.location).toList();
        if (locations.length > 0) {
          final bounds = boundsFromLatLngList(locations);
          _mapController.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );
        } else {
          _mapController.animateCamera(
            CameraUpdate.newLatLng(locationIssueState.location.toLatLng()),
          );
        }
      },
      child: FutureBuilder<Location>(
          future: _initialLocation,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? BlocBuilder<IssuesBloc, IssuesState>(
                    builder: (context, state) {
                      print(
                          'rebuilt'); // TODO: make the todos get saved for double the area so that the widget doesn't update every time
                      Set<Marker> markers = {};
                      if (state is IssuesLoadedState) {
                        markers = state.issues
                            .map((issues) => issues.toMarker())
                            .toSet();
                      }
                      var initialCameraPosition = CameraPosition(
                        target: LatLng(
                            snapshot.data.latitude, snapshot.data.longitude),
                        zoom: 10,
                      );

                      return GoogleMap(
                        initialCameraPosition: initialCameraPosition,
                        mapType: MapType.normal,
                        onCameraMove: (CameraPosition cameraPosition) async {
                          // add item to bloc for the rest of the UI to react properly
                          BlocProvider.of<IssuesBloc>(context).add(
                            GetIssuesWithinMapBoundsEvent(
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
                          BlocProvider.of<IssuesBloc>(context).add(
                            GetIssuesWithinMapBoundsEvent(
                              // TODO this code shouldn't exist
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
                  )
                : AppProgressIndicator();
          }),
    );
  }
}

extension on IssueFetched {
  Marker toMarker() {
    Location location = this.location;
    double distance = this.distance;

    // document id is the id of the marker since markers represent individual documents
    var markerId = MarkerId(this.id);
    return Marker(
      markerId: markerId,
      position: LatLng(location.latitude, location.longitude),
      // TODO: make use of anchor (custom dot that connects the icon to the location)
      infoWindow: InfoWindow(
        title: 'Magic Marker',
        snippet: '$distance km from query center',
      ),
    );
  }
}

LatLngBounds boundsFromLatLngList(List<Location> list) {
  assert(list.isNotEmpty);
  double x0, x1, y0, y1;
  for (Location latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
  }
  return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
}
