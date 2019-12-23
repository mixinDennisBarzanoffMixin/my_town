import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IssuesEvent {}

class GetIssuesAtLocationEvent extends IssuesEvent {
  final Position location;

  GetIssuesAtLocationEvent(this.location);
}

class GetIssuesAtLocationWithRadiusEvent extends GetIssuesAtLocationEvent {
  final double radius;
  GetIssuesAtLocationWithRadiusEvent(this.radius, Position location) : super(location);
}
