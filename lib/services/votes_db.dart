import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_town/screens/issues/issue-detail/vote.dart';

class VotesDatabaseService {
  Firestore _db = Firestore.instance;
  Future<void> updateUserVote(String userId, String issueId, UserVote vote) {
    Map<String, dynamic> data = {
      'userId': userId,
      'issueId': issueId,
    };
    if (vote != UserVote.Unvoted) {
      data['upvote'] = vote == UserVote.Upvoted;
    } else print('unvoting');
    return _db
        .collection('issue-votes')
        .document('${userId}_$issueId')
        .setData(data);
  }

  Stream<UserVote> getUserVote(String userId, String issueId) {
    return _db
        .collection('issue-votes')
        .document('${userId}_$issueId')
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data['upvote'] == null) {
        return UserVote.Unvoted;
      }
      return doc.data['upvote'] as bool ? UserVote.Upvoted : UserVote.Downvoted;
    });
  }
}
