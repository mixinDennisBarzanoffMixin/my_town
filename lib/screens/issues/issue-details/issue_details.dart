import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:my_town/screens/issues/issue-details/vote.dart';
import 'package:my_town/services/issues_db.dart';
import 'package:my_town/services/votes_db.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:my_town/shared/user.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:provider/provider.dart';

import 'i18n.dart';

class IssueDetailScreen extends StatefulWidget {
  const IssueDetailScreen({
    Key key,
  }) : super(key: key);
  @override
  _IssueDetailScreenState createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  VotesDatabaseService _votesDb = VotesDatabaseService();
  IssuesDatabaseService _issuesDb = IssuesDatabaseService();
  Stream<IssueFetchedWithBytes> issue$;
  Stream<UserVote> userVote$;
  bool isLoggedIn() => Provider.of<User>(context) != null;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = Provider.of<User>(context)?.uid;
    
    final IssueFetched issue = ModalRoute.of(context).settings.arguments;
    userVote$ = isLoggedIn() ? _votesDb.getUserVote(userId, issue.id) : null;
    issue$ = _issuesDb.getIssueById(issue.id).asyncMap(
          (issue) async => IssueFetchedWithBytes.fromIssueFetched(
            issue,
            await networkImageToByte(issue.thumbnailUrl ?? issue.imageUrl),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final IssueFetched issue = ModalRoute.of(context).settings.arguments;
    final String issueId = issue.id;
    final userId = Provider.of<User>(context).uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Details'.i18n),
      ),
      body: StreamBuilder<IssueFetched>(
        initialData: issue,
        stream: issue$,
        builder: (context, issueSnapshot) {
          if (issueSnapshot.hasData) {
            final issue = issueSnapshot.data;
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  height: 300,
                  child: Hero(
                    tag: issue.id, // the tag for the animations much match
                    child: issue.hasThumbnail
                        ? (issue is IssueFetchedWithBytes
                            ? FadeInImage.memoryNetwork(
                                placeholder: issue.imageBytes,
                                image: issue.imageUrl,
                                fit: BoxFit.cover, // cover the parent
                                fadeInDuration: Duration(milliseconds: 100),
                                fadeOutDuration: Duration(milliseconds: 100),
                              )
                            : Image.network(issue.imageUrl))
                        : (issue is IssueFetchedWithBytes)
                            ? Image.memory(
                                issue.imageBytes,
                                // if no thumb, show only real image
                              )
                            : Image.network(
                                issue.imageUrl), // no animation otherwise
                                // TODO too much code duplication
                  ),
                ),
                StreamBuilder<UserVote>(
                  stream: userVote$,
                  builder: (context, voteSnapshot) {
                    if (voteSnapshot.hasData) {
                      final vote = voteSnapshot.data;
                      final isUpvote = vote == UserVote.Upvoted;
                      var isDownvote = vote == UserVote.Downvoted;
                      final redWhen = (bool shouldBeRed) =>
                          shouldBeRed ? Colors.red : Colors.black;
                      return Row(
                        children: <Widget>[
                          VoteButton(
                            icon: Icons.thumb_up,
                            totalVoteCount: issue.upvotes ?? 0,
                            color: redWhen(isUpvote),
                            onPressed: !isLoggedIn() ? null : () {
                              final newVote = vote == UserVote.Unvoted ||
                                      vote == UserVote.Downvoted
                                  ? UserVote.Upvoted
                                  : UserVote.Unvoted;

                              print('newVote: $newVote, prevVote: $vote');
                              print('issue: ${issueId}, userId: ${userId}');
                              _votesDb.updateUserVote(userId, issueId, newVote);
                            },
                          ),
                          VoteButton(
                            icon: Icons.thumb_down,
                            totalVoteCount: issue.downvotes ?? 0,
                            color: redWhen(isDownvote),
                            onPressed: !isLoggedIn() ? null : () {
                              final newVote = vote == UserVote.Unvoted ||
                                      vote == UserVote.Upvoted
                                  ? UserVote.Downvoted
                                  : UserVote.Unvoted;
                              _votesDb.updateUserVote(userId, issueId, newVote);
                            },
                          )
                        ],
                      );
                    } else
                      return AppProgressIndicator();
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(issue.translatedDetailsOrDefault(I18n.language)),
                ),
              ],
            );
          } else {
            return AppProgressIndicator();
          }
        },
      ),
    );
  }
}

class VoteButton extends StatelessWidget {
  final int totalVoteCount;
  final void Function() onPressed;
  final Color color;
  final IconData icon;
  const VoteButton({
    Key key,
    @required this.totalVoteCount,
    @required this.onPressed,
    @required this.color,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        IconButton(
          icon: Icon(
            icon,
            color: this.color,
          ),
          onPressed: this.onPressed,
        ),
        Text('${this.totalVoteCount}'),
      ],
    );
  }
}
