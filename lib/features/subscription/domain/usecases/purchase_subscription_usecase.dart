import 'package:me_and_you/features/subscription/domain/entities/user_subscription_entity.dart';
import 'package:me_and_you/features/subscription/domain/repositories/subscription_repository.dart';

class PurchaseSubscriptionUseCase {
  final SubscriptionRepository _repository;

  PurchaseSubscriptionUseCase(this._repository);

  Future<void> execute(UserSubscriptionEntity subscription) async {
    return _repository.purchaseSubscription(subscription);
  }
}
