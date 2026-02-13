import '../entities/subscription_plan_entity.dart';
import '../repositories/subscription_repository.dart';

class GetPlansUseCase {
  final SubscriptionRepository _repository;

  GetPlansUseCase(this._repository);

  Stream<List<SubscriptionPlanEntity>> execute({bool activeOnly = true}) {
    if (activeOnly) {
      return _repository.getActiveSubscriptionPlans();
    }
    return _repository.getAllSubscriptionPlans();
  }
}
