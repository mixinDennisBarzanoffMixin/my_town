import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class Issue {
  String details;
  dynamic position;
  File imageFile;

  Issue({
    // todo fix this
    @required this.details,
    @required this.position,
    @required this.imageFile,
  });
}

class ReportProblem extends StatefulWidget {
  @override
  _ReportProblemState createState() => _ReportProblemState();
}

class _ReportProblemState extends State<ReportProblem> {
  File _imageFile;
  final _formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  Geoflutterfire geo = Geoflutterfire();
  var locator = Geolocator();
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://my-site-c41d6.appspot.com');
  Firestore db = Firestore.instance;
  StorageUploadTask _imageTask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report a problem"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: 'Submit', // todo test
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                var pos = await locator.getCurrentPosition();
                GeoFirePoint point = geo.point(
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                );
                var issue = Issue(
                  details: _textEditingController.text,
                  imageFile: _imageFile,
                  position: point.data,
                );
                var imageTask = await _saveToDb(issue);
                setState(() {
                  this._imageTask = imageTask;
                });
              }
            },
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
              ),
            if (_imageTask != null) Uploader(uploadTask: _imageTask)
          ],
        ),
      ),
    );
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

//
//  /// Remove image
//  void _clear() {
//    setState(() => _imageFile = null);
//  }

  Future<StorageUploadTask> _saveToDb(Issue issue) async {
    var firestoreRef = await db.collection('issues').add({
      'position': issue.position,
      'details': issue.details,
    });

    var storageRef =
        _storage.ref().child('images/${firestoreRef.documentID}.jpg');

    var task = storageRef.putFile(issue.imageFile);
    task.onComplete.then(
      (snapshot) async {
        return firestoreRef.setData({
          'imageUrl': await storageRef.getDownloadURL(),
        }, merge: true);
      },
    );
    return task;
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
    }
  }
}
