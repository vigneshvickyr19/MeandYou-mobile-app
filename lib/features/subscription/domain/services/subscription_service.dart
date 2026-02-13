import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../data/models/user_subscription_model.dart';
import '../entities/user_subscription_entity.dart';

class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserSubscriptionEntity?> getUserSubscription(String userId) async {
    final doc = await _firestore.collection(FirebaseConstants.userSubscriptions).doc(userId).get();
    if (!doc.exists) return null;
    return UserSubscriptionModel.fromMap(doc.data()!, doc.id);
  }

  Future<bool> isPremiumActive(String userId) async {
    final sub = await getUserSubscription(userId);
    if (sub == null) return false;
    return sub.isPremium;
  }

  Future<UserSubscriptionEntity?> getUserPlan(String userId) async {
    return await getUserSubscription(userId);
  }

  // Middleware like check
  Future<void> checkUserSubscription(String userId) async {
    // This could also be used to trigger updates if needed
    final sub = await getUserSubscription(userId);
    if (sub != null && sub.status == SubscriptionStatus.active && sub.expiryDate.isBefore(DateTime.now())) {
      // Logic to mark as expired if not already handled by backend
      // But user said user_subscriptions writable only by backend
    }
  }
}
