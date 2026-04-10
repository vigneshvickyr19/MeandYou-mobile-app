import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/benefit_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';

class SubscriptionRemoteDataSource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Benefits
  Future<void> createBenefit(BenefitModel benefit) async {
    await _firestore.collection(FirebaseConstants.benefits).add(benefit.toMap());
  }

  Future<void> updateBenefit(BenefitModel benefit) async {
    await _firestore
        .collection(FirebaseConstants.benefits)
        .doc(benefit.id)
        .update(benefit.toMap(isUpdate: true));
  }

  Stream<List<BenefitModel>> getBenefits() {
    return _firestore.collection(FirebaseConstants.benefits).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BenefitModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Subscription Plans
  Future<void> createSubscriptionPlan(SubscriptionPlanModel plan) async {
    await _firestore.collection(FirebaseConstants.subscriptionPlans).add(plan.toMap());
  }

  Future<void> updateSubscriptionPlan(SubscriptionPlanModel plan) async {
    await _firestore
        .collection(FirebaseConstants.subscriptionPlans)
        .doc(plan.id)
        .update(plan.toMap(isUpdate: true));
  }

  Stream<List<SubscriptionPlanModel>> getActiveSubscriptionPlans() {
    return _firestore
        .collection(FirebaseConstants.subscriptionPlans)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SubscriptionPlanModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<SubscriptionPlanModel>> getAllSubscriptionPlans() {
    return _firestore.collection(FirebaseConstants.subscriptionPlans).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SubscriptionPlanModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // User Subscriptions
  Stream<UserSubscriptionModel?> getUserSubscription(String userId) {
    return _firestore
        .collection(FirebaseConstants.userSubscriptions)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserSubscriptionModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> purchaseSubscription(UserSubscriptionModel subscription) async {
    final batch = _firestore.batch();

    // 1. Update current subscription
    final subRef = _firestore.collection(FirebaseConstants.userSubscriptions).doc(subscription.userId);
    batch.set(subRef, subscription.toMap());

    // 2. Add to history
    final historyRef = _firestore.collection(FirebaseConstants.subscriptionHistory).doc();
    batch.set(historyRef, {
      ...subscription.toMap(),
      'purchaseDate': FieldValue.serverTimestamp(),
      'id': historyRef.id,
    });

    await batch.commit();
  }

  Stream<List<UserSubscriptionModel>> getSubscriptionHistory(String userId) {
    return _firestore
        .collection(FirebaseConstants.subscriptionHistory)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final history = snapshot.docs
          .map((doc) => UserSubscriptionModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort in-memory to avoid mandatory composite index requirement
      history.sort((a, b) => b.startDate.compareTo(a.startDate));
      return history;
    });
  }
}
