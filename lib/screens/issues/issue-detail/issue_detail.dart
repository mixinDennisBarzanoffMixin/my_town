import 'package:flutter/material.dart';
import 'package:my_town/screens/issues/issue-detail/vote.dart';
import 'package:my_town/services/issues_db.dart';
import 'package:my_town/services/votes_db.dart';
import 'package:my_town/shared/Issue_fetched.dart';
import 'package:my_town/shared/progress_indicator.dart';
import 'package:my_town/shared/user.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:provider/provider.dart';

class IssueDetailScreen extends StatefulWidget {
  final IssueFetchedWithBytes issueFetchedWithBytes;
  final String issueId;

  const IssueDetailScreen({
    Key key,
    @required this.issueId,
    this.issueFetchedWithBytes,
  }) : super(key: key);
  @override
  _IssueDetailScreenState createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  VotesDatabaseService _votesDb = VotesDatabaseService();
  IssuesDatabaseService _issuesDb = IssuesDatabaseService();
  Stream<IssueFetchedWithBytes> issue$;
  Stream<UserVote> userVote$;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = Provider.of<User>(context).uid;

    userVote$ = _votesDb.getUserVote(userId, widget.issueId);
    issue$ = _issuesDb
        .getIssueById(widget.issueId)
        .asyncMap(
          (issue) async => IssueFetchedWithBytes.fromIssueFetched(
            issue,
            await networkImageToByte(issue.thumbnailUrl ?? issue.imageUrl),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final String issueId = widget.issueId;
    final userId = Provider.of<User>(context).uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Issue Details"),
      ),
      body: StreamBuilder<IssueFetchedWithBytes>(
        initialData: widget.issueFetchedWithBytes,
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
                        ? FadeInImage.memoryNetwork(
                            placeholder: issue.imageBytes,
                            image: issue.imageUrl,
                            fit: BoxFit.cover, // cover the parent
                            fadeInDuration: Duration(milliseconds: 100),
                            fadeOutDuration: Duration(milliseconds: 100),
                          )
                        : Image.memory(
                            issue
                                .imageBytes, // if no thumb, show only real image
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
                            totalVoteCount: issue.upvotes ?? 0,
                            color: redWhen(isUpvote),
                            onPressed: () {
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
                            onPressed: () {
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
                  child: Text(issue.details),
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
