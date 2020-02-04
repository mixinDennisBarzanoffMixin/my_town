part of 'settings_bloc.dart';

@immutable
class SettingsState {
  final bool showMap;

  const SettingsState(this.showMap);
}

class InitialSettingsState extends SettingsState {
  const InitialSettingsState() : super(true);
}

