import '../entities/benefit_entity.dart';
import '../entities/subscription_plan_entity.dart';
import '../entities/user_subscription_entity.dart';

abstract class SubscriptionRepository {
  // Benefits
  Future<void> createBenefit(BenefitEntity benefit);
  Future<void> updateBenefit(BenefitEntity benefit);
  Stream<List<BenefitEntity>> getBenefits();

  // Subscription Plans
  Future<void> createSubscriptionPlan(SubscriptionPlanEntity plan);
  Future<void> updateSubscriptionPlan(SubscriptionPlanEntity plan);
  Stream<List<SubscriptionPlanEntity>> getActiveSubscriptionPlans();
  Stream<List<SubscriptionPlanEntity>> getAllSubscriptionPlans();

  // User Subscriptions
  Stream<UserSubscriptionEntity?> getUserSubscription(String userId);
  Future<void> purchaseSubscription(UserSubscriptionEntity subscription);
  Stream<List<UserSubscriptionEntity>> getSubscriptionHistory(String userId);
}
