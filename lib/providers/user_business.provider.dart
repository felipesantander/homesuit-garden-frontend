import 'package:garden_homesuit/models/user_business.model.dart';
import 'package:garden_homesuit/services/user_business.service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userBusinessProvider =
    AsyncNotifierProvider<UserBusinessNotifier, List<UserBusiness>>(() {
      return UserBusinessNotifier();
    });

class UserBusinessNotifier extends AsyncNotifier<List<UserBusiness>> {
  @override
  Future<List<UserBusiness>> build() async {
    return []; // Usually we might not fetch a list of all connections blindly,
    // but this gives a base state if needed.
  }

  Future<UserBusiness> getUserBusiness(String id) async {
    final service = ref.read(userBusinessServiceProvider);
    return await service.getUserBusiness(id);
  }

  Future<UserBusiness> createUserBusiness(int userId, String businessId) async {
    final service = ref.read(userBusinessServiceProvider);
    return await service.createUserBusiness(
      userId: userId,
      businessId: businessId,
    );
  }

  Future<UserBusiness> updateUserBusiness(
    String id,
    String newBusinessId,
  ) async {
    final service = ref.read(userBusinessServiceProvider);
    return await service.updateUserBusiness(id, newBusinessId: newBusinessId);
  }

  Future<void> deleteUserBusiness(String id) async {
    final service = ref.read(userBusinessServiceProvider);
    await service.deleteUserBusiness(id);
  }
}
