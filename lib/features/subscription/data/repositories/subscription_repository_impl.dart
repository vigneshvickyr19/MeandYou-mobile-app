import '../../domain/entities/benefit_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../../domain/entities/user_subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/benefit_model.dart';
import '../models/subscription_plan_model.dart';

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
}
