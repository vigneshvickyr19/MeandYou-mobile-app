import '../entities/subscription_plan_entity.dart';
import '../repositories/subscription_repository.dart';

class ManagePlanUseCase {
  final SubscriptionRepository _repository;

  ManagePlanUseCase(this._repository);

  Future<void> create(SubscriptionPlanEntity plan) async {
    await _repository.createSubscriptionPlan(plan);
  }

  Future<void> update(SubscriptionPlanEntity plan) async {
    await _repository.updateSubscriptionPlan(plan);
  }
}
