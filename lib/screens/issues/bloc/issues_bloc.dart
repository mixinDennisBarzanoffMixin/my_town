import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:my_town/services/issues_db.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/location.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:rxdart/rxdart.dart';
import './bloc.dart';

const _defaultRadius = 14.0;

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  IssuesDatabaseService _db = IssuesDatabaseService();

  @override
  IssuesState get initialState => InitialIssuesState();

  @override
  Stream<IssuesState> mapEventToState(IssuesEvent event) async* {
    yield IssuesLoadingState();
    if (event is GetIssuesAtLocationEvent) {
      yield* getIssuesLoadedStatesStream(_defaultRadius, event.location);
    } else if (event is GetIssuesAtLocationWithRadiusEvent) {
      yield* getIssuesLoadedStatesStream(event.radius, event.location);
    }
  }

  @override
  Stream<IssuesState> transformEvents(events, next) {
    // The stream never ends so asyncMap doesn't work,
    // we need to switch to the new Stream values when they appear
    return events.switchMap(next);
  }

  @override
  Stream<IssuesState> transformStates(Stream<IssuesState> states) {
    // we need to know the history for the nested routes that get to listen after that
    return states.shareReplay(maxSize: 1);
  }

  Stream<IssuesLoadedState> getIssuesLoadedStatesStream(
          double radius, Location location) =>
      _db.getIssues(radius, location)
          .map((issues) async {
            final futures = issues.map((issue) async =>
                await networkImageToByte(issue.thumbnailUrl ?? issue.imageUrl));
            final bytesList = await Future.wait(futures);
            return getIssueFetchedWithBytes(issues, bytesList);
          })
          .switchMap((it) => Stream.fromFuture(it))
          .map(
            (issues) {
              print(issues.length);
              return IssuesLoadedState(issues: issues);
            },
          );
}

List<IssueFetchedWithBytes> getIssueFetchedWithBytes(
    List<IssueFetched> issues, List<Uint8List> bytesList) {
  var downloadedIssues = <IssueFetchedWithBytes>[];
  for (int i = 0; i < issues.length; i++) {
    final issue = issues[i];
    final bytes = bytesList[i];
    final issueFetchedWithBytes =
        IssueFetchedWithBytes.fromIssueFetched(issue, bytes);
    downloadedIssues.add(issueFetchedWithBytes);
  }
  return downloadedIssues;
}
