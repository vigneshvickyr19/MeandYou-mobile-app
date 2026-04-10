import 'package:me_and_you/features/subscription/domain/entities/benefit_entity.dart';
import 'package:me_and_you/features/subscription/domain/entities/subscription_plan_entity.dart';
import 'package:me_and_you/features/subscription/domain/entities/user_subscription_entity.dart';
import 'package:me_and_you/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:me_and_you/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:me_and_you/features/subscription/data/models/benefit_model.dart';
import 'package:me_and_you/features/subscription/data/models/subscription_plan_model.dart';
import 'package:me_and_you/features/subscription/data/models/user_subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createBenefit(BenefitEntity benefit) async {
    await _remoteDataSource.createBenefit(BenefitModel.fromEntity(benefit));
  }

  @override
  Future<void> updateBenefit(BenefitEntity benefit) async {
    await _remoteDataSource.updateBenefit(BenefitModel.fromEntity(benefit));
  }

  @override
  Stream<List<BenefitEntity>> getBenefits() {
    return _remoteDataSource.getBenefits();
  }

  @override
  Future<void> createSubscriptionPlan(SubscriptionPlanEntity plan) async {
    await _remoteDataSource.createSubscriptionPlan(SubscriptionPlanModel.fromEntity(plan));
  }

  @override
  Future<void> updateSubscriptionPlan(SubscriptionPlanEntity plan) async {
    await _remoteDataSource.updateSubscriptionPlan(SubscriptionPlanModel.fromEntity(plan));
  }

  @override
  Stream<List<SubscriptionPlanEntity>> getActiveSubscriptionPlans() {
    return _remoteDataSource.getActiveSubscriptionPlans();
  }

  @override
  Stream<List<SubscriptionPlanEntity>> getAllSubscriptionPlans() {
    return _remoteDataSource.getAllSubscriptionPlans();
  }

  @override
  Stream<UserSubscriptionEntity?> getUserSubscription(String userId) {
    return _remoteDataSource.getUserSubscription(userId);
  }

  @override
  Future<void> purchaseSubscription(UserSubscriptionEntity subscription) async {
    await _remoteDataSource.purchaseSubscription(UserSubscriptionModel.fromEntity(subscription));
  }

  @override
  Stream<List<UserSubscriptionEntity>> getSubscriptionHistory(String userId) {
    return _remoteDataSource.getSubscriptionHistory(userId);
  }
}
