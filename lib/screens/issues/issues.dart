import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/issue_detail.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/screens/issues/filter_results_widget.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/backdrop.dart';
import 'package:my_town/shared/drawer.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:typed_data';
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
    return Backdrop(
      frontTitle: Text('Issues in your area'),
      frontLayer: SizedBox(
        // todo use less widgets
        height: 200.0,
        width: double.infinity, // stretch to the parent width
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: BlocBuilder<IssuesBloc, IssuesState>(
            builder: (context, state) {
              return ListView(
                children: [
                  if (state is IssuesLoadingState)
                    AppProgressIndicator()
                  else if (state is IssuesLoadedState)
                    for (var issue in state.issues) IssueCard(issue)
                ],
                scrollDirection: Axis.vertical,
              );
            },
          ),
        ),
      ),
      frontHeading: Container(
        height: 50,
        alignment: Alignment.center,
        child: Text('Issue images'),
      ),
      backTitle: Text('Options'),
      backLayer: FilterResultsWidget(),
      drawer: AppDrawer(),
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
  Future<Uint8List> imageBytesFuture;

  @override
  void initState() { 
    super.initState();
    imageBytesFuture =
        networkImageToByte(widget.issue.thumbnailUrl ?? widget.issue.imageUrl);
  }
  @override
  void didUpdateWidget(IssueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issue != widget.issue)
      imageBytesFuture =
        networkImageToByte(widget.issue.thumbnailUrl ?? widget.issue.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: imageBytesFuture,
      builder: (context, imageBytes) {
        return SizedBox(
          width: double.infinity,
          height: 400,
          child: Card(
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
                imageBytes.hasData
                    ? GestureDetector(
                        child: Hero(
                          tag: widget.issue.imageUrl,
                          child: Image.memory(imageBytes.data),
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/issue_detail',
                          arguments: IssueDetailArguments(
                            widget.issue,
                            imageBytes.data,
                          ),
                        ),
                      )
                    : AppProgressIndicator(),
                Text(widget.issue.details),
              ],
            ),
          ),
        );
      },
    );
  }
}
