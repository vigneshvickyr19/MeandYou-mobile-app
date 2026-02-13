import '../entities/user_subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetUserSubscriptionUseCase {
  final SubscriptionRepository _repository;

  GetUserSubscriptionUseCase(this._repository);

  Stream<UserSubscriptionEntity?> execute(String userId) {
    return _repository.getUserSubscription(userId);
  }
}
