import 'package:me_and_you/features/subscription/domain/entities/user_subscription_entity.dart';
import 'package:me_and_you/features/subscription/domain/repositories/subscription_repository.dart';

class GetSubscriptionHistoryUseCase {
  final SubscriptionRepository _repository;

  GetSubscriptionHistoryUseCase(this._repository);

  Stream<List<UserSubscriptionEntity>> execute(String userId) {
    return _repository.getSubscriptionHistory(userId);
  }
}
