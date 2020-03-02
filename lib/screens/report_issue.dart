import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_town/services/issues_db.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/location.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:my_town/shared/user.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FormIssue {
  String details;
  dynamic position;
  File imageFile;

  FormIssue({
    // todo fix this
    @required this.details,
    @required this.position,
    @required this.imageFile,
  });
}

class TaskAndDocId {
  final StorageUploadTask task;
  final String documentID;

  TaskAndDocId(this.task, this.documentID);
}

class ReportIssueScreen extends StatefulWidget {
  @override
  _ReportIssueScreenState createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  final Geoflutterfire geo = Geoflutterfire();
  final locator = Geolocator();
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://my-town-ba556.appspot.com');
  final Firestore _db = Firestore.instance;
  final IssuesDatabaseService _issuesDb = IssuesDatabaseService();
  final Geolocator _locator = Geolocator();

  File _imageFile;
  StorageUploadTask _imageTask;

  bool _alreadySubmitted = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'Report Scaffold');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Report a Problem"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Submit', // todo test
            onPressed: _alreadySubmitted ? null : _onPressedSubmitIssueData,
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
//              IconButton(
//                icon: Icon(Icons.photo_library),
//                onPressed: () => _pickImage(ImageSource.gallery),
//              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _textEditingController,
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Details about the issue';
                }
                return null;
              },
            ),
            if (_imageFile != null)
              Image.file(
                _imageFile,
                height: 300,
                fit: BoxFit.cover,
              ),
            if (_imageTask != null) Uploader(uploadTask: _imageTask)
          ],
        ),
      ),
    );
  }

  _onPressedSubmitIssueData() async {
    setState(() {
      _alreadySubmitted = true;
    });
    if (_formKey.currentState.validate()) {
      var pos = await locator.getCurrentPosition();
      GeoFirePoint point = geo.point(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      final issue = FormIssue(
        details: _textEditingController.text,
        imageFile: _imageFile,
        position: point.data,
      );
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Searching for similar issues'),
          duration: Duration(seconds: 2),
        ),
      );
      final similarIssue = await _findSimilarIssueTo(issue);
      if (similarIssue != null) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Similar Issue Found'),
                content: Text(
                  'A similar issue to the one you are about to submit already exists in the Database.',
                  softWrap: true,
                ),
                actions: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/issue_details',
                          arguments: similarIssue);
                    },
                    child: Text('View'),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  FlatButton(
                    onPressed: () async {
                      await _submitIssueAndNavigateToIt(issue);
                    },
                    child: Text('Proceed with upload'),
                  )
                ],
              );
            });
        setState(() {
          _alreadySubmitted = false; // the dialog was dismissed
        });
      } else {
        await _submitIssueAndNavigateToIt(issue);
      }
    }
  }

  _submitIssueAndNavigateToIt(FormIssue issue) async {
    try {
      setState(() {
        _alreadySubmitted = true;
      });
      final id = await _submitIssue(issue);
      final issueFetched = await _issuesDb.getIssueById(id).first;
      Navigator.of(context)
          .pushReplacementNamed('/issue_details', arguments: issueFetched);
    } catch (e) {
      print(e);
    }
  }

  Future<String> _submitIssue(FormIssue issue) async {
    final taskAndId = await _saveToDb(issue);
    final imageTask = taskAndId.task;
    var issueId = taskAndId.documentID;
    setState(() {
      this._imageTask = imageTask;
    });
    return issueId;
  }

  /// Select an image via gallery or camera
  _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    if (selected != null) {
      // if the user exists the camera without picture -> null
      setState(() {
        _imageFile = selected;
      });
    }
  }

  Future<TaskAndDocId> _saveToDb(FormIssue issue) async {
    print('Saving to database');
    final userId = Provider.of<User>(context, listen: false).uid;
    var firestoreRef = await _db.collection('issues').add({
      'position': issue.position,
      'details': issue.details,
      'ownerId': userId, // TODO: not ideal, needs fixing
    });

    var storageRef =
        _storage.ref().child('${firestoreRef.documentID}/image.jpg');

    var task = storageRef.putFile(
        issue.imageFile,
        StorageMetadata(customMetadata: {
          'uid': userId,
        }));
    task.onComplete.then(
      (snapshot) async {
        await firestoreRef.setData({
          'imageUrl': await storageRef.getDownloadURL(),
        }, merge: true);
      },
    );
    return TaskAndDocId(task, firestoreRef.documentID);
  }

  Future<IssueFetched> _findSimilarIssueTo(FormIssue issue) async {
    Future<double> textSimilarityBetween(String text1, String text2) async {
      final encodedText1 = Uri.encodeComponent(text1);
      final encodedText2 = Uri.encodeComponent(text2);
      final token = '7ddb04d3bff345f7933e9c9a3b7fa038';
      final lang = 'en';
      final encodedUrl =
          'https://api.dandelion.eu/datatxt/sim/v1/?text1=$encodedText1&text2=$encodedText2&lang=$lang&token=$token';
      final response = await http.get(encodedUrl);
      final jsonResponse = json.decode(response.body);
      // print(jsonResponse.toString());
      final double similarity = jsonResponse['similarity'];
      return similarity;
    }

    final position = await _locator.getCurrentPosition();
    final issuesNearBy = await this
        ._issuesDb
        .getIssues(.5, Location.fromPosition(position))
        .first;
    final similarities = {
      for (var issueNearBy in issuesNearBy)
        await textSimilarityBetween(issue.details, issueNearBy.details):
            issueNearBy
    };
    print('similarities:');
    print(similarities);
    final sortedSimilarities = similarities.keys.toList()..sort();
    final highestSimilarityKey = sortedSimilarities.last;
    if (highestSimilarityKey > 0.5) {
      // really similar
      print(highestSimilarityKey);
      final similarIssue = similarities[highestSimilarityKey];
      print(similarIssue);
      return similarIssue;
    } else {
      // no similar issues
      print('no similar issues');
      return null;
    }
  }
}

/// Widget used to handle the management of the upload
class Uploader extends StatefulWidget {
  final StorageUploadTask uploadTask;

  Uploader({Key key, this.uploadTask}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  @override
  Widget build(BuildContext context) {
    if (widget.uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: widget.uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;

          double progressPercent =
              event != null ? event.bytesTransferred / event.totalByteCount : 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.uploadTask.isComplete)
                Text(
                  '🎉🎉🎉',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    height: 2,
                    fontSize: 30,
                  ),
                ),
              LinearProgressIndicator(value: progressPercent),
              Text(
                '${(progressPercent * 100).toStringAsFixed(2)} % ',
                style: TextStyle(fontSize: 50),
              ),
            ],
          );
        },
      );
    } else
      return AppProgressIndicator();
  }
}
