import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/screens/issues/issues.dart';
import 'package:my_town/screens/screens.dart';
import 'package:my_town/screens/settings/bloc/settings_bloc.dart';
import 'package:my_town/screens/settings/settings.dart';
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
        StreamProvider<User>.value(
          value: AuthService().user$,
          lazy: false,
        ),
        BlocProvider<IssuesBloc>(create: (_) => IssuesBloc()),
        BlocProvider<SettingsBloc>(create: (_) => SettingsBloc()),
      ],
      child: MaterialApp(
        initialRoute: '/issues',
        routes: {
          '/issues': (context) => IssuesScreen(),
          '/login': (context) => LoginScreen(),
          '/issue_details': (context) => IssueDetailScreen(),
          '/report_issue': (context) => ReportIssueScreen(),
          '/settings': (context) => SettingsScreen(),
        },
      ),
    );
  }
}
