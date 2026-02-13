import '../entities/benefit_entity.dart';
import '../repositories/subscription_repository.dart';

class GetBenefitsUseCase {
  final SubscriptionRepository _repository;

  GetBenefitsUseCase(this._repository);

  Stream<List<BenefitEntity>> execute() {
    return _repository.getBenefits();
  }
}
