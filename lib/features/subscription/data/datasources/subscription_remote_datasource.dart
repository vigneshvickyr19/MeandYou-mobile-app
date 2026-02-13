import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/benefit_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';

class SubscriptionRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
