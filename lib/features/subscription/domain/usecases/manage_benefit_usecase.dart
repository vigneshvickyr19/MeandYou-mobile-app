import '../entities/benefit_entity.dart';
import '../repositories/subscription_repository.dart';

class ManageBenefitUseCase {
  final SubscriptionRepository _repository;

  ManageBenefitUseCase(this._repository);

  Future<void> create(BenefitEntity benefit) async {
    await _repository.createBenefit(benefit);
  }

  Future<void> update(BenefitEntity benefit) async {
    await _repository.updateBenefit(benefit);
  }
}
