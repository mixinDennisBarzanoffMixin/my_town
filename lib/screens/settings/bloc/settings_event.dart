part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {
  const SettingsEvent();
}

class MapVisibilitySettingsEvent extends SettingsEvent {
  final bool showMap;

  const MapVisibilitySettingsEvent(this.showMap);
}
