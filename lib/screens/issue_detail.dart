import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_town/shared/Issue_fetched.dart';

class IssueDetailPage extends StatelessWidget {
  final IssueFetched issue;
  final Uint8List detailImageBytes;

  IssueDetailPage(this.issue, this.detailImageBytes);

  @override
  Widget build(BuildContext context) {
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
              tag: issue.imageUrl, // the tag for the animations much match
              child: issue.hasThumbnail
                  ? FadeInImage.memoryNetwork(
                      placeholder: detailImageBytes,
                      image: issue.imageUrl,
                      fit: BoxFit.cover, // cover the parent
                      fadeInDuration: Duration(milliseconds: 100),
                      fadeOutDuration: Duration(milliseconds: 100),
                    )
                  : Image.memory(detailImageBytes), // no animation otherwise
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(issue.details),
          ),
        ],
      ),
    );
  }
}
