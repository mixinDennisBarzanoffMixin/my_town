import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_town/shared/Issue_fetched.dart';

class IssueDetailArguments {
  final IssueFetched issue;
  final Uint8List detailImageBytes;

  IssueDetailArguments(this.issue, this.detailImageBytes);
}

class IssueDetailScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final IssueDetailArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text("Issue Details"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            height: 300,
            child: Hero(
              tag: args.issue.imageUrl, // the tag for the animations much match
              child: args.issue.hasThumbnail
                  ? FadeInImage.memoryNetwork(
                      placeholder: args.detailImageBytes,
                      image: args.issue.imageUrl,
                      fit: BoxFit.cover, // cover the parent
                      fadeInDuration: Duration(milliseconds: 100),
                      fadeOutDuration: Duration(milliseconds: 100),
                    )
                  : Image.memory(args.detailImageBytes), // no animation otherwise
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(args.issue.details),
          ),
        ],
      ),
    );
  }
}
