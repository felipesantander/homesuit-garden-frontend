import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/users/user_form_body.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/users.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserFormView extends ConsumerWidget {
  final String? userId; // If null, it's a create view

  const UserFormView({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId != null) {
      final usersAsync = ref.watch(usersProvider);

      return usersAsync.when(
        data: (users) {
          final intId = int.tryParse(userId!);
          final user = users.firstWhere(
            (u) => u.id == intId,
            orElse: () => throw Exception('Usuario no encontrado'),
          );

          return _buildScaffold(context, user);
        },
        loading: () => const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (err, stack) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context),
          body: Center(
            child: Text(
              'Error cargando usuario: $err',
              style: const TextStyle(color: AppColors.negative),
            ),
          ),
        ),
      );
    }

    // Creating a new user
    return _buildScaffold(context, null);
  }

  Widget _buildScaffold(BuildContext context, dynamic user) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - 48, // 24 top + 24 bottom padding
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: UserFormBody(user: user),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        userId == null ? 'Nuevo Usuario' : 'Editar Usuario',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
        onPressed: () => context.pop(),
      ),
    );
  }
}
