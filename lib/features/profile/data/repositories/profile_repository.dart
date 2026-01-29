import '../../../../core/models/profile_model.dart';
import '../../../../core/services/database_service.dart';

class ProfileRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<ProfileModel?> getProfile(String userId) async {
    return await _dbService.getProfileSetup(userId);
  }
}
