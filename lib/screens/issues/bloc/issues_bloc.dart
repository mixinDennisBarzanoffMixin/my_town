import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:rxdart/rxdart.dart';
import './bloc.dart';

const _defaultRadius = 14.0;

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  Geoflutterfire geo = Geoflutterfire();
  Firestore db = Firestore.instance;

  @override
  IssuesState get initialState => InitialIssuesState();

  @override
  Stream<IssuesState> mapEventToState(IssuesEvent event) async* {
    yield IssuesLoadingState();
    if (event is GetIssuesAtLocationEvent) {
      print('current location');
      print(event.location);
      var issues =
           getIssuesLoadedStatesStream(_defaultRadius, event.location);
      yield* issues;
    } else if (event is GetIssuesAtLocationWithRadiusEvent) {
      yield* getIssuesLoadedStatesStream(event.radius, event.location);
    }
  }

  @override
  Stream<IssuesState> transformEvents(events, next) {
    // The stream never ends so asyncMap doesn't work, 
    // we need to switch to the new Stream values when they appear
    return (events as Observable<IssuesEvent>).switchMap(next);
  }

  Stream<IssuesLoadedState> getIssuesLoadedStatesStream(
          double radius, Position location) =>
      getIssues(radius, location).map(
        (issues) => IssuesLoadedState(issues: issues),
      );

  Stream<List<IssueFetched>> getIssues(double radius, Position location) {
    // TODO: move this to the DB service
    var issuesRef = db.collection('issues');

    GeoFirePoint toPoint(Position position) =>
        geo.point(latitude: position.latitude, longitude: position.longitude);

    return geo
        .collection(collectionRef: issuesRef)
        .within(
          center: toPoint(location),
          radius: radius,
          field: 'position',
          strictMode: true,
        )
        .map(
          (issues) => issues
              .map((document) => IssueFetched.fromGeoFireDocument(document))
              .toList(),
        );
  }
}
