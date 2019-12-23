import 'package:meta/meta.dart';
import 'package:my_town/shared/Issue_fetched.dart';

@immutable
abstract class IssuesState {}
  
class InitialIssuesState extends IssuesState {}

class IssuesLoadingState extends IssuesState {}

class IssuesLoadedState extends IssuesState {
  final List<IssueFetched> issues;
  IssuesLoadedState({@required this.issues});
}