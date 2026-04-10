import 'package:me_and_you/features/subscription/domain/entities/subscription_plan_entity.dart';
import 'package:me_and_you/features/subscription/domain/repositories/subscription_repository.dart';

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
