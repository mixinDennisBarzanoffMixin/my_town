import 'package:meta/meta.dart';
import 'package:my_town/shared/location.dart';

@immutable
abstract class IssuesEvent {
  const IssuesEvent();
}

class GetIssuesAtLocationEvent extends IssuesEvent {
  final Location location;

  GetIssuesAtLocationEvent(this.location);
}

class GetIssuesAtLocationWithRadiusEvent extends IssuesEvent {
  final double radius;
  final Location location;
  const GetIssuesAtLocationWithRadiusEvent(this.radius, this.location);
}
