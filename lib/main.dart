import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_town/screens/screens.dart';
import 'package:my_town/services/auth.dart';
import 'package:provider/provider.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(value: AuthService().user)
      ],
      child: MaterialApp(
        routes: {
          '/': (context) => IssuesScreen(),
          '/login': (context) => LoginScreen(),
          '/issue_detail': (context) => IssueDetailScreen(),
          '/report_issue': (context) => ReportIssueScreen(),
        },
      ),
    );
  }
}
