import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/business/business_card.component.dart';
import 'package:garden_homesuit/components/business/business_form.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BusinessesView extends ConsumerWidget {
  const BusinessesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            onAdd: () => _showFormDialog(context),
            onRefresh: () => ref.read(businessesProvider.notifier).refresh(),
          ),
          Expanded(
            child: businessesAsync.when(
              data: (businesses) => _BusinessesList(businesses: businesses),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _ErrorState(error: err),
            ),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, {Business? business}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 450,
          child: BusinessForm(
            business: business,
            onSaved: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    business == null
                        ? 'Negocio creado exitosamente'
                        : 'Negocio actualizado exitosamente',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onRefresh;

  const _Header({required this.onAdd, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
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
                  Icons.business_center_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Negocios',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Administra la relación entre usuarios y máquinas',
                    style: TextStyle(
                      fontSize: 14,
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
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                color: AppColors.primary,
                tooltip: 'Refrescar',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'NUEVO NEGOCIO',
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
      ),
    );
  }
}

class _BusinessesList extends StatelessWidget {
  final List<Business> businesses;

  const _BusinessesList({required this.businesses});

  @override
  Widget build(BuildContext context) {
    if (businesses.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron negocios registrados',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 220,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        final business = businesses[index];
        return BusinessCard(
          business: business,
          onEdit: () => const BusinessesView()._showFormDialog(
            context,
            business: business,
          ),
        );
      },
    );
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
            'Error al cargar negocios: $error',
            style: const TextStyle(color: AppColors.negative),
          ),
        ],
      ),
    );
  }
}
