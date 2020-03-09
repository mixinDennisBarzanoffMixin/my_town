import 'package:flutter/material.dart';
import 'i18n.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String achievementToShow = ModalRoute.of(context).settings.arguments;
    print('Pretending to be animating for: $achievementToShow');
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'.i18n),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Image.asset('assets/badges/reporter.png', width: 80),
            title: Text('Reporter'),
            subtitle: Text('Submit your first report'),
          ),
        ],
      ),
    );
  }
}
