import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/shared/user.dart';
import 'package:provider/provider.dart';

class IssueLocations {
  final String text;
  const IssueLocations._(this.text);
  static const IssueLocations HomeLocation =
      const IssueLocations._('Saved location');
  static const IssueLocations CurrentLocation =
      const IssueLocations._('Current location');
  static const IssueLocations ChooseOnMap =
      const IssueLocations._('Choose on map');
}

class FilterResultsWidget extends StatefulWidget {
  final IssueLocations dropdownValue;
  const FilterResultsWidget(
      {Key key, this.dropdownValue = IssueLocations.CurrentLocation})
      : super(key: key);
  static final List<IssueLocations> _dropdownItems = const [
    IssueLocations.HomeLocation,
    IssueLocations.CurrentLocation,
    IssueLocations.ChooseOnMap,
  ];
  // final formKey = GlobalKey<FormState>();

  @override
  _FilterResultsWidgetState createState() => _FilterResultsWidgetState();
}

extension on GeoPoint {
  toPosition() {
    return Position(latitude: this.latitude, longitude: this.longitude);
  }
}

class _FilterResultsWidgetState extends State<FilterResultsWidget> {
  IssueLocations _issueLocation = IssueLocations.HomeLocation;
  Geolocator locator = Geolocator();

  @override
  void didUpdateWidget(FilterResultsWidget oldWidget) {
    
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InputDecorator(
          decoration: InputDecoration(
            filled: false,
            hintText: 'Choose Location',
            prefixIcon: Icon(Icons.location_on),
            labelText: widget.dropdownValue == null ? 'Issues where?' : 'From',
            // errorText: _errorText,
          ),
          isEmpty: widget.dropdownValue == null,
          child: DropdownButton<IssueLocations>(
            value: _issueLocation,
            isDense: true,
            onChanged: (IssueLocations newValue) async {
              setState(() {
                _issueLocation = newValue;
              });
              switch (newValue) {
                case IssueLocations.ChooseOnMap:
                  var currentPosition = await locator.getCurrentPosition();
                  Navigator.pushNamed(
                    context,
                    '/issues_map',
                    arguments: currentPosition.toLatLng(),
                  );
                  break;
                case IssueLocations.CurrentLocation:
                  var currentPosition = await locator.getCurrentPosition();
                  print(currentPosition);
                  BlocProvider.of<IssuesBloc>(context)
                      .add(GetIssuesAtLocationEvent(currentPosition));
                  break;
                case IssueLocations.HomeLocation:
                  var userHomeLocation =
                      Provider.of<User>(context).homeLocation;

                  BlocProvider.of<IssuesBloc>(context).add(
                      GetIssuesAtLocationEvent(userHomeLocation.toPosition()));
                  break;
              }
              print(newValue.text);
            },
            items: [
              for (var value in FilterResultsWidget._dropdownItems)
                DropdownMenuItem<IssueLocations>(
                  value: value,
                  child: Text(value.text),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on Position {
  toLatLng() {
    return LatLng(this.latitude, this.longitude);
  }
}