import 'package:flutter/material.dart';
import 'package:my_town/services/auth.dart';
import 'package:my_town/shared/user.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();

  // todo this should be a higher hierarchy component
  AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 70,
                  width: 70,
                  child: CircleAvatar(
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user.photoUrl)
                        : AssetImage('assets/anonymous_avatar.png'),
                  ),
                ),
                Text(
                    user?.displayName != null
                        ? user.displayName
                        : 'Helpful citizen',
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.white)),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ...[
            if (Provider.of<User>(context) == null) // TODO: extract as a service method
              ListTile(
                title: Text('Sign in'),
                onTap: () {
                  this._auth.googleSignIn();
                },
              )
            else
              ListTile(
                title: Text('Sign out'),
                onTap: () {
                  this._auth.signOut();
                },
              ),
          ],
        ],
      ),
    );
  }
}
