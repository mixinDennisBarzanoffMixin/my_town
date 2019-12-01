import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_town/IssueFetched.dart';

class ViewIssue extends StatelessWidget {
  final IssueFetched issue;

  ViewIssue(this.issue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issue Details"),
      ),
      body: Column(
        children: <Widget>[
          Hero(
            tag: issue.imageUrl, // the tag for the animations much match
            child: CachedNetworkImage(
              imageUrl: issue.imageUrl,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(issue.details),
          )
        ],
      ),
    );
  }
}
