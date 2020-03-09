import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_town/screens/achievements/achievements.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/screens/issues/issues.dart';
import 'package:my_town/screens/screens.dart';
import 'package:my_town/screens/settings/bloc/settings_bloc.dart';
import 'package:my_town/screens/settings/settings.dart';
import 'package:my_town/services/auth.dart';
import 'package:my_town/shared/user.dart';
import 'package:provider/provider.dart';
import 'package:i18n_extension/i18n_widget.dart';


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
          '/issues':        (context) => I18n(child: IssuesScreen()),
          '/login':         (context) => I18n(child: LoginScreen()),
          '/issue_details': (context) => I18n(child: IssueDetailScreen()),
          '/report_issue':  (context) => I18n(child: ReportIssueScreen()),
          '/settings':      (context) => I18n(child: SettingsScreen()),
          '/achievements':  (context) => I18n(child: AchievementsScreen()),
        },
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'), // English
          const Locale('bg'), // Bulgarian
        ],
      ),
    );
  }
}
