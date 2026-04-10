import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/match_model.dart';
import '../../../home/data/models/like_model.dart';
import '../../../../core/models/user_model.dart';

class LinksService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static const String _matchesCollection = FirebaseConstants.matches;
  static const String _likesCollection = FirebaseConstants.likes;
  static const String _usersCollection = FirebaseConstants.users;

  // Stream of matches for the current user
  Stream<List<MatchModel>> getMatches(String userId) {
    return _firestore
        .collection(_matchesCollection)
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MatchModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Stream of likes received by the current user
  Stream<List<LikeModel>> getLikesReceived(String userId) {
    return _firestore
        .collection(_likesCollection)
        .where('toUserId', isEqualTo: userId)
        .where('isMutual', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LikeModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get user details for matches
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
