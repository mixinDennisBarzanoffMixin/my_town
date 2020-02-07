import 'package:cached_network_image/cached_network_image.dart';
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
    print(user);
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
                        ? CachedNetworkImageProvider(user.photoUrl)
                        : AssetImage('assets/anonymous_avatar.png'),
                  ),
                ),
                Text(
                  user?.displayName != null
                      ? user.displayName
                      : 'Helpful citizen',
                  style: Theme.of(context)
                      .textTheme // TODO: extract as a theme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          ...[
            if (user == null) // TODO: extract as a service method
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
