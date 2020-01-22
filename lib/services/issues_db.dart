import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_town/shared/location.dart';
import '../shared/Issue_fetched.dart';
// import 'package:rxdart/rxdart.dart';

class IssuesDatabaseService {
  Geoflutterfire _geo = Geoflutterfire();
  Firestore _db = Firestore.instance;

  Stream<List<IssueFetched>> getIssues(double radius, Location location) {
    var issuesRef = _db.collection('issues');

    GeoFirePoint toPoint(Location position) =>
        _geo.point(latitude: position.latitude, longitude: position.longitude);

    print('getting issues');
    return _geo
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

  Stream<IssueFetched> getIssueById(String id) {
    var issueRef = _db.document('issues/$id');
    return issueRef
        .snapshots()
        .map((document) => IssueFetched.fromGeoFireDocument(document));
  }
}
