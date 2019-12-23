import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/fire_map/fire_map.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/screens/issues/issues.dart';
import 'package:my_town/screens/screens.dart';
import 'package:my_town/services/auth.dart';
import 'package:my_town/shared/user.dart';
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
        StreamProvider<User>.value(value: AuthService().user$),
        BlocProvider<IssuesBloc>.value(value: IssuesBloc()),
      ],
      child: MaterialApp(
        initialRoute: '/login',
        routes: {
          '/issues': (context) => IssuesScreen(),
          '/issues_map': (context) => FireMap(),
          '/login': (context) => LoginScreen(),
          '/issue_detail': (context) => IssueDetailScreen(),
          '/report_issue': (context) => ReportIssueScreen(),
        },
      ),
    );
  }
}
