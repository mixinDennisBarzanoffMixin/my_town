import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:my_town/screens/issues/issue-detail/vote.dart';
import 'package:my_town/services/issues_db.dart';
import 'package:my_town/services/votes_db.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:my_town/shared/user.dart';
import 'package:provider/provider.dart';

class IssueDetailArguments {
  final IssueFetched issue;
  final Uint8List detailImageBytes;

  IssueDetailArguments(this.issue, this.detailImageBytes);
}

class IssueDetailScreen extends StatefulWidget {
  @override
  _IssueDetailScreenState createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  VotesDatabaseService _votesDb = VotesDatabaseService();
  IssuesDatabaseService _issuesDb = IssuesDatabaseService();
  Stream<IssueFetched> issue$;
  Stream<UserVote> userVote$;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final IssueDetailArguments args = ModalRoute.of(context).settings.arguments;
    final userId = Provider.of<User>(context).uid;
    final issueId = args.issue.id;

    issue$ = _issuesDb.getIssueById(issueId);
    userVote$ = _votesDb.getUserVote(userId, issueId);
  }

  @override
  Widget build(BuildContext context) {
    final IssueDetailArguments args = ModalRoute.of(context).settings.arguments;
    final userId = Provider.of<User>(context).uid;
    final issueId = args.issue.id;
    return Scaffold(
      appBar: AppBar(
        title: Text("Issue Details"),
      ),
      body: StreamBuilder<IssueFetched>(
        stream: issue$,
        builder: (context, snapshot) {
          var resolvedIssue = snapshot.data ?? args.issue;
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                height: 300,
                child: Hero(
                  tag:
                      resolvedIssue.id, // the tag for the animations much match
                  child: resolvedIssue.hasThumbnail
                      ? FadeInImage.memoryNetwork(
                          placeholder: args.detailImageBytes,
                          image: resolvedIssue.imageUrl,
                          fit: BoxFit.cover, // cover the parent
                          fadeInDuration: Duration(milliseconds: 100),
                          fadeOutDuration: Duration(milliseconds: 100),
                        )
                      : Image.memory(
                          args.detailImageBytes, // TODO: change in thumbnail won't be reflected
                        ), // no animation otherwise
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
                          totalVoteCount: snapshot.data?.upvotes ?? 0,
                          color: redWhen(isUpvote),
                          onPressed: () {
                            final newVote = vote == UserVote.Unvoted || vote == UserVote.Downvoted
                                ? UserVote.Upvoted
                                : UserVote.Unvoted;
                                
                                print('newVote: $newVote, prevVote: $vote');
                            _votesDb.updateUserVote(userId, issueId, newVote);
                          },
                        ),
                        VoteButton(
                          icon: Icons.thumb_down,
                          totalVoteCount: snapshot.data?.downvotes ?? 0,
                          color: redWhen(isDownvote),
                          onPressed: () {
                            final newVote = vote == UserVote.Unvoted || vote == UserVote.Upvoted
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
                child: Text(resolvedIssue.details),
              ),
            ],
          );
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
