import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/garden/garden_card.component.dart';
import 'package:garden_homesuit/components/garden/garden_form.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/business.model.dart';
import 'package:garden_homesuit/models/garden.model.dart';
import 'package:garden_homesuit/providers/gardens.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/view_filters.provider.dart';

class GardensMobileView extends ConsumerWidget {
  const GardensMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardensAsync = ref.watch(gardensProvider);
    final selectedBusinessIds = ref.watch(gardenBusinessFilterProvider);
    final businessesAsync = ref.watch(businessesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Jardines',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref.read(gardensProvider.notifier).refresh(),
            tooltip: 'Refrescar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: gardensAsync.when(
          data: (gardens) {
            return businessesAsync.when(
              data: (businesses) => _GroupedGardensList(
                gardens: gardens,
                businesses: businesses,
                selectedBusinessIds: selectedBusinessIds,
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (err, _) => _ErrorState(error: err),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          error: (err, stack) => _ErrorState(error: err),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _showFormBottomSheet(context),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showFormBottomSheet(BuildContext context, {Garden? garden}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: GardenForm(
                garden: garden,
                onSaved: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupedGardensList extends StatelessWidget {
  final List<Garden> gardens;
  final List<dynamic> businesses;
  final Set<String> selectedBusinessIds;

  const _GroupedGardensList({
    required this.gardens,
    required this.businesses,
    required this.selectedBusinessIds,
  });

  @override
  Widget build(BuildContext context) {
    final filteredGardens = gardens.where((garden) {
      if (selectedBusinessIds.isEmpty) return true;
      return selectedBusinessIds.contains(garden.business);
    }).toList();

    if (filteredGardens.isEmpty) {
      return const _EmptyState();
    }

    final Map<String, List<Garden>> grouped = {};
    for (final garden in filteredGardens) {
      final bizId = garden.business;
      grouped.putIfAbsent(bizId, () => []).add(garden);
    }

    final sortedBizIds = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedBizIds.length,
      itemBuilder: (context, bizIndex) {
        final bizId = sortedBizIds[bizIndex];
        final bizGardens = grouped[bizId]!;
        final business = businesses.cast<Business?>().firstWhere(
          (b) => b?.idBusiness == bizId,
          orElse: () => null,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                business?.name ?? 'Negocio Desconocido',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            ...bizGardens.map(
              (garden) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 220,
                  child: GardenCard(
                    garden: garden,
                    onEdit: () => const GardensMobileView()
                        ._showFormBottomSheet(context, garden: garden),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco_outlined,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Sin jardines aún',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Crea tu primer espacio de cultivo para organizar tus sensores y plantas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: AppColors.negative),
      ),
    );
  }
}
