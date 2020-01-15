import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/fire_map/fire_map.dart';
import 'package:my_town/screens/issues/issue-detail/issue_detail.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/backdrop.dart';
import 'package:my_town/shared/drawer.dart';
import 'package:my_town/shared/location.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension on GeoPoint {
  // firestore point to latlng
  LatLng toLatLng() => LatLng(this.latitude, this.longitude);
}

class IssuesScreen extends StatefulWidget {
  @override
  State createState() => IssuesScreenState();
}

class IssuesScreenState extends State<IssuesScreen> {
  Firestore db = Firestore.instance;
  Geolocator locator = Geolocator();

  Stream<List<IssueFetched>> issues$;

  @override
  build(context) {
    return BlocBuilder<IssuesBloc, IssuesState>(
      builder: (context, state) {
        print('state');
        print(state);
        return Backdrop(
          frontTitle: Text('Issues in your area'),
          frontLayer: SizedBox(
            // todo use less widgets
            height: 200.0,
            width: double.infinity, // stretch to the parent width
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: [
                  if (state is IssuesLoadingState)
                    AppProgressIndicator()
                  else if (state is IssuesLoadedState)
                    for (var issue in state.issues) IssueCard(issue)
                ],
                scrollDirection: Axis.vertical,
              ),
            ),
          ),
          frontHeadingText: state is IssuesLoadedState
              ? '${state.issues.length} issues'
              : 'Issues',
          backTitle: Text('Options'),
          backLayer: FutureBuilder<Location>(
            future: this
                .locator
                .getCurrentPosition() // TODO: see how you're gonna get the position
                .then((position) => Location.fromPosition(position)),
            builder: (context, location) {
              if (location.hasData) return FireMap(location.data);
              return AppProgressIndicator();
            },
          ),
          drawer: AppDrawer(),
        );
      },
    );
  }
}

class IssueCard extends StatelessWidget {
  const IssueCard(
    this.issue, {
    Key key,
  }) : super(key: key);

  final IssueFetchedWithBytes issue;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/anonymous_avatar.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('Username'),
                    )
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                )
              ],
            ),
          ),
          GestureDetector(
            child: Hero(
              tag: issue.id,
              child: SizedBox(
                width: double.infinity,
                child: Image.memory(issue.imageBytes,
                    width: 200, fit: BoxFit.fitWidth),
              ),
            ),
            onTap: () => Navigator.pushNamed(
              context,
              '/issue_detail',
              arguments: issue.id,
            ),
          ),
          Container(
            child: Text(issue.details),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
        ],
      ),
    );
  }
}
