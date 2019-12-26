import 'package:meta/meta.dart';
import 'package:my_town/shared/location.dart';

@immutable
abstract class IssuesEvent {}

class GetIssuesAtLocationEvent extends IssuesEvent {
  final Location location;

  GetIssuesAtLocationEvent(this.location);
}

class GetIssuesAtLocationWithRadiusEvent extends GetIssuesAtLocationEvent {
  final double radius;
  GetIssuesAtLocationWithRadiusEvent(this.radius, Location location) : super(location);
}
