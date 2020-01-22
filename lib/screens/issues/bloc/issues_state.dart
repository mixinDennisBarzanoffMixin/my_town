import 'package:meta/meta.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/location.dart';

@immutable
abstract class IssuesState {
  const IssuesState();
}

class InitialIssuesState extends IssuesState {}

class IssuesLoadingState extends IssuesState {}

class IssuesLoadedState extends IssuesState {
  final List<IssueFetched> issues;
  const IssuesLoadedState({@required this.issues});
}

class IssuesLoadedAtLocationState extends IssuesLoadedState {
  final Location location;

  const IssuesLoadedAtLocationState({
    @required List<IssueFetched> issues,
    @required this.location,
  }) : super(issues: issues);
}
