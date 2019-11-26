import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_town/report_problem.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreenData {
  // used as a tuple (like a Kotlin data class)
  LatLngBounds bounds;
  CameraPosition position;

  MapScreenData(this.bounds, this.position);
}

class MapVisibleRegionBloc {
  // BehaviorSubject is used because it keeps only the latest item
  BehaviorSubject<MapScreenData> _mapScreenData = new BehaviorSubject();

  Observable<MapScreenData> get mapScreenData$ => _mapScreenData.stream;

  void dispose() {
    _mapScreenData.close();
  }

  void addVisibleRegion(
      LatLngBounds visibleRegion, CameraPosition cameraPosition) {
    _mapScreenData.sink.add(MapScreenData(visibleRegion, cameraPosition));
  }
}

void main() {
  debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("My town"),
        ),
        body: FireMap(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Builder( // todo remove
          builder: (context) => FloatingActionButton.extended(
            icon: Icon(Icons.add),
            label: Text("Report Problem"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportProblem(),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 60,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
          ),
//          shape: CircularNotchedRectangle(),
        ),
      ),
    );
  }
}

class FireMap extends StatefulWidget {
  @override
  State createState() => FireMapState();
}

class FireMapState extends State<FireMap> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Geolocator locator = Geolocator();
  Firestore db = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  GoogleMapController _mapController;

  MapVisibleRegionBloc mapVisibleRegionBloc = MapVisibleRegionBloc();

  Observable<Set<Marker>> markers$;
  Observable<Set<String>> imageUrls$;
  Future<Position> _initialLocation;

  @override
  void initState() {
    super.initState();
    _auth.signInAnonymously();
    var locationDocuments$ = _locationDocuments().shareReplay(maxSize: 1);

    var markers$ = locationDocuments$
        .map((List<DocumentSnapshot> documents) => documents.map((document) {
              GeoPoint pos = document.data['position']['geopoint'];
              double distance = document.data['distance'];

              // document id is the id of the marker since markers represent individual documents
              var markerId = MarkerId(document.documentID);
              return Marker(
                markerId: markerId,
                position: LatLng(pos.latitude, pos.longitude),
                // todo make use of anchor (custom dot that connects the icon to the location)
                infoWindow: InfoWindow(
                    title: 'Magic Marker',
                    snippet: '$distance kilometers from query center'),
              );
            }).toSet());

    var images$ = locationDocuments$
        .map(
          (documentList) => documentList
              .map(
                (document) => document.data['imageUrl'] as String,
                // element at index zero is the chosen one
              )
              .toSet(),
        )
        .doOnData(print);

    this.markers$ = markers$;
    this.imageUrls$ = images$;
    this._initialLocation = locator.getCurrentPosition();
  }

  @override
  build(context) {
    var margin = 20.0;
    print(MediaQuery.of(context).size.height);
    print(_initialLocation);
    return Stack(
      children: [
        FutureBuilder(
          future: _initialLocation,
          builder: (context, AsyncSnapshot<Position> initialLocationSnapshot) {
            // markers$ is subscribed to only once the initial location is gotten
            if (initialLocationSnapshot.hasData)
              /*
                  render the map and subscribe to the markers
                  (which depend not on the user location,
                  but on the map screen location, but by setting it,
                  we also set the screen location)
                  only after the location has been taken.
                 */
              return StreamBuilder(
                stream: markers$,
                builder: (context, AsyncSnapshot<Set<Marker>> markersSnapshot) {
                  var initialCameraPosition = CameraPosition(
                    target: LatLng(
                      initialLocationSnapshot.data.latitude,
                      initialLocationSnapshot.data.longitude,
                    ),
                    zoom: 10,
                  );

                  return GoogleMap(
                    initialCameraPosition: initialCameraPosition,
                    mapType: MapType.normal,
                    onCameraMove: (CameraPosition cameraPosition) async {
                      // add item to bloc for the rest of the UI to react properly
                      mapVisibleRegionBloc.addVisibleRegion(
                        await _mapController.getVisibleRegion(),
                        cameraPosition,
                      );
                    },
                    onMapCreated: (mapController) async {
                      setState(() {
                        this._mapController = mapController;
                      });
                      mapVisibleRegionBloc.addVisibleRegion(
                        await _mapController.getVisibleRegion(),
                        initialCameraPosition,
                      );
                    },
                    // no maximum zoom
                    minMaxZoomPreference: MinMaxZoomPreference(null, null),
                    // data will be null in waiting state
                    //todo make the list of markers a set
                    markers: markersSnapshot.data?.toSet(),
                  );
                },
              );
            else
              return Center(
                child: CircularProgressIndicator(),
              );
          },
        ),
        StreamBuilder(
          stream: imageUrls$,
          builder: (context, AsyncSnapshot<Set<String>> urlsSnapshot) {
            return SlidingUpPanel(
              maxHeight: MediaQuery.of(context).size.height,
              minHeight: 250,
              panel: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 200.0,
                  width: MediaQuery.of(context).size.width - margin * 2,
                  child: ListView(
                    children: [
                      if (urlsSnapshot.hasData)
                        for (var url in urlsSnapshot.data)
                          Container(
                            margin: EdgeInsets.all(10.0),
                            width: 160.0,
                            child: Image.network(url),
                          )
                    ],
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Observable<List<DocumentSnapshot>> _locationDocuments() {
    GeoFirePoint center(LatLng position) =>
        geo.point(latitude: position.latitude, longitude: position.longitude);

    Future<double> getMapVisibleRadius(LatLngBounds visibleRegion) async {
      var screenDiameterInMeters = await locator.distanceBetween(
          visibleRegion.southwest.latitude,
          visibleRegion.southwest.longitude,
          visibleRegion.northeast.latitude,
          visibleRegion.northeast.longitude);

      var screenDiameterInKilometers = screenDiameterInMeters / 1000;

      return screenDiameterInKilometers;
    }

    var cameraPosition$ = mapVisibleRegionBloc.mapScreenData$.debounceTime(
      Duration(milliseconds: 150),
    ); // location updates are very frequent by default

    return cameraPosition$.switchMap(
      (mapScreenData) {
        var visibleRegionBounds = mapScreenData.bounds;
        var radius = getMapVisibleRadius(visibleRegionBounds);
        var location = mapScreenData.position.target;

        print('New map position update: ' + location.toString());

        // Make a reference to firestore
        var ref = db.collection('issues');

        return Observable.fromFuture(radius).switchMap(
          // wait for the radius to be calculated
          (radius) => geo.collection(collectionRef: ref).within(
                center: center(location),
                radius: radius,
                field: 'position',
                strictMode: true,
              ),
        );
      },
    );
  }
}
