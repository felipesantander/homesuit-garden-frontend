import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/users/user_card.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/user.model.dart';
import 'package:garden_homesuit/providers/users.provider.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class UsersView extends ConsumerWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 32),
              Expanded(
                child: usersAsync.when(
                  data: (users) => _UsersList(users: users),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  error: (err, stack) => _ErrorState(error: err),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Usuarios',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Administra el acceso y roles de tu equipo de trabajo',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => ref.read(usersProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.primary,
              tooltip: 'Refrescar Lista',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 16),
            if (ref
                    .watch(authStateProvider)
                    ?.components
                    .contains('users_add') ??
                false)
              ElevatedButton.icon(
                onPressed: () => context.push('/users/new'),
                icon: const Icon(Icons.person_add_rounded, size: 20),
                label: const Text(
                  'NUEVO USUARIO',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(
                        Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
              ),
          ],
        ),
      ],
    );
  }
}

class _UsersList extends ConsumerWidget {
  final List<UserModel> users;

  const _UsersList({required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay usuarios registrados',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: UserCard(
            user: user,
            onEdit: () => context.push('/users/edit/${user.id}'),
            onDelete: () => _confirmDelete(context, ref, user),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Eliminar Usuario',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar al usuario ${user.username}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.negative,
              foregroundColor: Colors.white,
            ),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(usersProvider.notifier).deleteUser(user.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario eliminado'),
              backgroundColor: AppColors.positive,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.negative,
            ),
          );
        }
      }
    }
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.negative),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.negative),
          ),
        ],
      ),
    );
  }
}
