import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/models/user.model.dart';
import 'package:garden_homesuit/services/user.service.dart';
import 'package:garden_homesuit/providers/user_business.provider.dart';

final usersProvider = AsyncNotifierProvider<UsersNotifier, List<UserModel>>(() {
  return UsersNotifier();
});

class UsersNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  Future<List<UserModel>> build() async {
    return _fetchUsers();
  }

  Future<List<UserModel>> _fetchUsers() async {
    final service = ref.read(userServiceProvider);
    return await service.getUsers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<void> createUser(
    Map<String, dynamic> userData, {
    String? roleId,
  }) async {
    final service = ref.read(userServiceProvider);
    final newUser = await service.createUser(userData);

    if (roleId != null && roleId.isNotEmpty) {
      await service.assignRole(newUser.id, roleId);
    }
    await refresh();
  }

  Future<void> updateUser(
    int userId,
    Map<String, dynamic> userData, {
    String? roleId,
  }) async {
    final service = ref.read(userServiceProvider);
    await service.updateUser(userId, userData);

    if (roleId != null && roleId.isNotEmpty) {
      await service.assignRole(userId, roleId);
    }
    await refresh();
  }

  Future<void> deleteUser(int id) async {
    final service = ref.read(userServiceProvider);
    await service.deleteUser(id);
    await refresh();
  }

  Future<void> createUserWithConnection({
    required Map<String, dynamic> userData,
    String? roleId,
    List<String> businessIds = const [],
  }) async {
    final service = ref.read(userServiceProvider);
    final newUser = await service.createUser(userData);

    if (roleId != null && roleId.isNotEmpty) {
      await service.assignRole(newUser.id, roleId);
    }

    if (businessIds.isNotEmpty) {
      for (final bId in businessIds) {
        await ref
            .read(userBusinessProvider.notifier)
            .createUserBusiness(newUser.id, bId);
      }
    }

    await refresh();
  }

  Future<void> updateUserWithConnection({
    required int userId,
    required Map<String, dynamic> userData,
    String? roleId,
    List<String> businessIds = const [],
    List<String> idUserBusinesses = const [],
    List<String> oldBusinessIds = const [],
  }) async {
    final service = ref.read(userServiceProvider);
    await service.updateUser(userId, userData);

    if (roleId != null && roleId.isNotEmpty) {
      await service.assignRole(userId, roleId);
    }

    // Determine missing from new list to connect
    final addedIds = businessIds
        .where((element) => !oldBusinessIds.contains(element))
        .toList();

    // Determine the ones that were omitted from new list to delete
    final removedIds = oldBusinessIds
        .where((element) => !businessIds.contains(element))
        .toList();

    for (final newBId in addedIds) {
      await ref
          .read(userBusinessProvider.notifier)
          .createUserBusiness(userId, newBId);
    }

    for (final removedBId in removedIds) {
      // Find corresponding connection Id
      final idx = oldBusinessIds.indexOf(removedBId);
      if (idx != -1 && idx < idUserBusinesses.length) {
        final idUserBusinessToDelete = idUserBusinesses[idx];
        await ref
            .read(userBusinessProvider.notifier)
            .deleteUserBusiness(idUserBusinessToDelete);
      }
    }

    await refresh();
  }
}
