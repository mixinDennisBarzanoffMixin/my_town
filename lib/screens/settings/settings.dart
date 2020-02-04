import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/settings/bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          BlocBuilder<SettingsBloc, SettingsState>(
            condition: (oldState, newState) =>
                oldState.showMap != newState.showMap,
            builder: (context, state) => SwitchListTile(
              title: Text('Show the issues map'),
              value: state.showMap,
              onChanged: (bool showMap) {
                BlocProvider.of<SettingsBloc>(context).add(
                  MapVisibilitySettingsEvent(showMap),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
