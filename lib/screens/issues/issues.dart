import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/fire_map/fire_map.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/backdrop.dart';
import 'package:my_town/shared/drawer.dart';
import 'package:my_town/shared/location.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';

extension on GeoPoint {
  // firestore point to latlng
  LatLng toLatLng() => LatLng(this.latitude, this.longitude);
}

class IssuesScreen extends StatelessWidget {
  final Geolocator locator = Geolocator();

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

class IssueCard extends StatefulWidget {
  const IssueCard(
    this.issue, {
    Key key,
  }) : super(key: key);

  final IssueFetched issue;

  @override
  _IssueCardState createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
  Future<Uint8List> bytes;
  @override
  void didChangeDependencies() {
    bytes =
        networkImageToByte(widget.issue.thumbnailUrl ?? widget.issue.imageUrl);
    super.didChangeDependencies();
  }

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
          FutureBuilder<Uint8List>(
              future: bytes,
              builder: (context, bytesSnapshot) {
                return bytesSnapshot.hasData
                    ? GestureDetector(
                        child: Hero(
                          tag: widget.issue.id,
                          child: SizedBox(
                            width: double.infinity,
                            child: Image.memory(
                              bytesSnapshot.data,
                              width: 200,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/issues/${widget.issue.id}',
                          arguments: IssueFetchedWithBytes.fromIssueFetched(
                            widget.issue,
                            bytesSnapshot.data,
                          ),
                        ),
                      )
                    : AppProgressIndicator();
              }),
          Container(
            child: Text(widget.issue.details),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
        ],
      ),
    );
  }
}
