import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_town/screens/issue_detail.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/bottom_app_bar.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:flutter/rendering.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';


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

extension IssueFetchedExtension on IssueFetched {
  Marker toMarker() {
    GeoPoint pos = this.geopoint;
    double distance = this.distance;

    // document id is the id of the marker since markers represent individual documents
    var markerId = MarkerId(this.id);
    return Marker(
      markerId: markerId,
      position: LatLng(pos.latitude, pos.longitude),
      // todo make use of anchor (custom dot that connects the icon to the location)
      infoWindow: InfoWindow(
        title: 'Magic Marker',
        snippet: '$distance km from query center',
      ),
    );
  }
}

class IssuesScreen extends StatefulWidget {
  @override
  State createState() => IssuesScreenState();
}

class IssuesScreenState
    extends State<IssuesScreen> /* with SingleTickerProviderStateMixin */ {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Geolocator locator = Geolocator();
  Firestore db = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  GoogleMapController _mapController;

  MapVisibleRegionBloc mapVisibleRegionBloc = MapVisibleRegionBloc();

  Observable<Set<Marker>> markers$;
  Observable<Set<String>> imageUrls$;
  Observable<List<IssueFetched>> issues$;
  Future<Position> _initialLocation;
  // AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // _controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 450),
    //   value: 1.0,
    // ); // todo use

    var issues$ = _issueDocuments()
        .map(
          (issues) => issues
              .map((document) => IssueFetched.fromGeoFireDocument(document))
              .toList(),
        )
        .doOnData(print)
        .shareReplay(maxSize: 1);

    var markers$ = issues$.map((List<IssueFetched> issues) =>
        issues.map((issue) => issue.toMarker()).toSet());

    var images$ = issues$
        .map(
          (issues) => issues.map((issue) {
            print(issues);
            return issue.thumbnailUrl ?? issue.imageUrl;
            // if there is still no url of lower quality - use the original one
          }
              // element at index zero is the chosen one
              ).toSet(),
        )
        .doOnData(print);

    this.issues$ = issues$;
    this.markers$ = markers$;
    this.imageUrls$ = images$;
    this._initialLocation = locator.getCurrentPosition();
  }

  @override
  build(context) {
    var margin = 20.0;
    print(MediaQuery.of(context).size.height);
    print(_initialLocation);
    return StreamBuilder<List<IssueFetched>>(
      stream: issues$,
      builder: (context, issuesSnapshot) {
        return SafeArea(
          child: Backdrop(
            backLayer: FutureBuilder(
              future: _initialLocation,
              builder:
                  (context, AsyncSnapshot<Position> initialLocationSnapshot) {
                // markers$ is subscribed to only once the initial location is gotten
                if (initialLocationSnapshot.hasData)
                  /*
                        render the map and subscribe to the markers
                        (which depend not on the user location,
                        but on the map screen location, but by setting it,
                        we also set the screen location)
                        only after the location has been taken.
                      */
                  return Builder(
                    builder: (context) {
                      print('rebuilt');
                      final markers = issuesSnapshot.data
                          ?.map((issues) => issues.toMarker());
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
                          print('map created');
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
                        markers: markers?.toSet(),
                      );
                    },
                  );
                else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              },
            ),
            frontLayer: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 200.0,
                width: MediaQuery.of(context).size.width - margin * 2,
                child: Builder(
                  builder: (context) {
                    return ListView(
                      children: [
                        if (issuesSnapshot.hasData)
                          for (var issue in issuesSnapshot.data)
                            IssueImage(issue)
                      ],
                      scrollDirection: Axis.horizontal,
                    );
                  },
                ),
              ),
            ),
            frontAction: IconButton(
              icon: Icon(Icons.android),
              onPressed: () {
                print('pressed');
              },
            ),
            frontTitle: Text('all issues'),
            backTitle: Text('Back'),
            frontHeading: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text('Issue images'),
            ),
          ),
        );
      },
    );
  }

  Observable<List<DocumentSnapshot>> _issueDocuments() {
    GeoFirePoint center(LatLng position) =>
        geo.point(latitude: position.latitude, longitude: position.longitude);

    Future<double> getMapVisibleRadius(LatLngBounds visibleRegion) async {
      var screenDiameterInMeters = await locator.distanceBetween(
        visibleRegion.southwest.latitude,
        visibleRegion.southwest.longitude,
        visibleRegion.northeast.latitude,
        visibleRegion.northeast.longitude,
      );

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

class IssueImage extends StatefulWidget {
  const IssueImage(
    this.issue, {
    Key key,
  }) : super(key: key);

  final IssueFetched issue;

  @override
  _IssueImageState createState() => _IssueImageState();
}

class _IssueImageState extends State<IssueImage> {
  Future<Uint8List> imageBytesFuture;
  @override
  void initState() {
    super.initState();
    imageBytesFuture =
        networkImageToByte(widget.issue.thumbnailUrl ?? widget.issue.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageBytesFuture,
      builder: (context, imageBytes) {
        return Container(
          margin: EdgeInsets.all(10.0),
          width: 160.0,
          child: imageBytes.hasData
              ? GestureDetector(
                  child: Container(
                    child: Hero(
                      tag: widget.issue.imageUrl,
                      child: Image.memory(imageBytes.data),
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IssueDetailScreen(
                        widget.issue,
                        imageBytes.data,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        );
      },
    );
  }
}
