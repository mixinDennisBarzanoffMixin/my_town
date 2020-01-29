import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/fire_map/fire_map.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/backdrop.dart';
import 'package:my_town/shared/drawer.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_town/shared/user.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:provider/provider.dart';

import 'filter_results_widget.dart';

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
            // todo useless widgets
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
          backLayer: Builder(
            builder: (context) {
              if (Provider.of<User>(context) == null) {
                //debug statement to disable the map
                return AppProgressIndicator();
              }
              return Stack(
                children: <Widget>[
                  FireMap(),
                  Positioned(
                    top: 10,
                    child: FilterResults(),
                  ),
                ],
              );
            },
          ),
          drawer: AppDrawer(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, 'report_issue');
            },
            child: Icon(Icons.add),
          ),
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
  void initState() {
    super.initState();
    _initImage();
  }

  @override
  void didUpdateWidget(IssueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issue.thumbnailUrl != widget.issue.thumbnailUrl ||
        oldWidget.issue.imageUrl != widget.issue.imageUrl) {
      _initImage();
    }
  }

  void _initImage() {
    bytes =
        networkImageToByte(widget.issue.thumbnailUrl ?? widget.issue.imageUrl);
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
                      child: const Text('Username'),
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
          SizedBox(
            width: double.infinity,
            height: 250, // this is the fixed size of the image
            child: FutureBuilder<Uint8List>(
                future: bytes,
                builder: (context, bytesSnapshot) {
                  return bytesSnapshot.hasData
                      ? GestureDetector(
                          child: Hero(
                            tag: widget.issue.id,
                            child: Image.memory(
                              bytesSnapshot.data,
                              width: double.infinity,
                              fit: BoxFit
                                  .fitWidth, // this is to make the image look good in the box
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
          ),
          Container(
            child: Text(widget.issue.details),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
        ],
      ),
    );
  }
}
