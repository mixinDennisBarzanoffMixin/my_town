part of 'issues_bloc.dart';

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
