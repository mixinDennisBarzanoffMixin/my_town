import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_town/screens/fire_map/fire_map.dart';
import 'package:my_town/screens/issues/bloc/bloc.dart';
import 'package:my_town/screens/settings/bloc/settings_bloc.dart';
import 'package:my_town/services/issues_db.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/backdrop.dart';
import 'package:my_town/shared/drawer.dart';
import 'package:my_town/shared/layout_breakpoints.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_town/shared/user.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:provider/provider.dart';
import 'filter_results_widget.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'i18n.dart';

extension on GeoPoint {
  // firestore point to latlng
  LatLng toLatLng() => LatLng(this.latitude, this.longitude);
}

class IssuesScreen extends StatelessWidget {
  final Geolocator locator = Geolocator();

  @override
  build(context) {
    Locale myLocale = Localizations.localeOf(context);
    print(myLocale.countryCode);
    print(myLocale.languageCode);
    print(myLocale.toLanguageTag());
    return BlocBuilder<IssuesBloc, IssuesState>(
      builder: (context, state) {
        print('state');
        print(state);
        return Backdrop(
          frontTitle: Text('Issues in your area'.i18n),
          frontLayer: SizedBox(
            // todo useless widgets
            width: double.infinity, // stretch to the parent width
            child: GridView.count(
              padding: EdgeInsets.symmetric(
                  horizontal: getIssuesGridGutter(context)),
              crossAxisCount: getIssueGridCount(context),
              crossAxisSpacing: getIssuesGridGutter(context),
              mainAxisSpacing: getIssuesGridGutter(context),
              children: [
                if (state is IssuesLoadingState)
                  AppProgressIndicator()
                else if (state is IssuesLoadedState)
                  for (var issue in state.issues) IssueCard(issue)
              ],
              scrollDirection: Axis.vertical,
            ),
          ),
          frontHeadingText: state is IssuesLoadedState
              ? 'N issues'.plural(state.issues.length)
              : 'N issues'.plural(0),
          backTitle: Text('Options'.i18n),
          backLayer: Builder(
            builder: (context) {
              return BlocBuilder<SettingsBloc, SettingsState>(
                  condition: (oldState, newState) =>
                      oldState.showMap != newState.showMap,
                  builder: (context, state) {
                    return Stack(
                      children: <Widget>[
                        if (state.showMap) FireMap(),
                        Positioned(
                          top: 10,
                          child: FilterResults(),
                        ),
                      ],
                    );
                  });
            },
          ),
          drawer: AppDrawer(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/report_issue');
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  int getIssueGridCount(BuildContext context) {
    ScreenSize size = getScreenSizeFrom(context);
    switch (size) {
      case ScreenSize.small:
        return 1;
      case ScreenSize.medium:
        return 2;
      case ScreenSize.large:
        return 3;
    }
  }

  double getIssuesGridGutter(BuildContext context) {
    ScreenSize size = getScreenSizeFrom(context);
    switch (size) {
      case ScreenSize.small:
        return 16;
      case ScreenSize.medium:
      case ScreenSize.large:
        return 24;
    }
  }
}

class IssueCard extends StatefulWidget {
  const IssueCard(
    this.issue, {
    Key key,
  }) : super(key: key);

  final IssueFetched issue;

  @override
  _IssueCardState createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
  Future<Uint8List> bytes;
  @override
  void initState() {
    super.initState();
    _initImage();
  }

  @override
  void didUpdateWidget(IssueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issue.thumbnailUrl != widget.issue.thumbnailUrl ||
        oldWidget.issue.imageUrl != widget.issue.imageUrl) {
      _initImage();
    }
  }

  void _initImage() {
    bytes =
        networkImageToByte(widget.issue.thumbnailUrl ?? widget.issue.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: constraints.maxWidth, // The card is as tall as it is wide
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/anonymous_avatar.png'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: const Text('Username'),
                        )
                      ],
                    ),
                    IssueOptionsButton(issue: widget.issue),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 250, // this is the fixed size of the image
                  child: FutureBuilder<Uint8List>(
                      future: bytes,
                      builder: (context, bytesSnapshot) {
                        return bytesSnapshot.hasData
                            ? GestureDetector(
                                child: Hero(
                                  tag: widget.issue.id,
                                  child: Image.memory(
                                    bytesSnapshot.data,
                                    width: double.infinity,
                                    fit: BoxFit
                                        .fitWidth, // this is to make the image look good in the box
                                  ),
                                ),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/issue_details',
                                  arguments:
                                      IssueFetchedWithBytes.fromIssueFetched(
                                    widget.issue,
                                    bytesSnapshot.data,
                                  ),
                                ),
                              )
                            : AppProgressIndicator();
                      }),
                ),
              ),
              Container(
                child: Text(widget.issue.translatedDetailsOrDefault(I18n.language)),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum IssueOptions {
  delete,
}

class IssueOptionsButton extends StatelessWidget {
  final IssuesDatabaseService _issuesDb = IssuesDatabaseService();
  IssueOptionsButton({
    Key key,
    @required this.issue,
  }) : super(key: key);

  final IssueFetched issue;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        if (canDeleteIssue(context)) ...[
          PopupMenuItem(
            child: Text('Delete'.i18n),
            value: IssueOptions.delete,
          ),
        ],
      ],
      onSelected: (option) {
        switch (option) {
          case IssueOptions.delete:
            _issuesDb.deleteIssueById(issue.id);
            break;
        }
      },
      icon: Icon(Icons.more_vert),
    );
  }

  bool canDeleteIssue(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    if (issue.ownerId == user.uid) {
      return true;
    } else if (user is Admin) {
      return true;
    }
    return false;
  }
}
