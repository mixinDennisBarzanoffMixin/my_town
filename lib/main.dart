import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_town/screens/issues.dart';
import 'package:my_town/screens/login.dart';
import 'package:my_town/screens/report_issue.dart';


void main() {
  debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
          '/': (context) => LoginScreen(),
          '/issues': (context) => FireMap(),
          // 'issue_detail': (context) => IssueDetail
          '/report_issue': (context) => ReportProblem(),
        },
    );
  }
}
