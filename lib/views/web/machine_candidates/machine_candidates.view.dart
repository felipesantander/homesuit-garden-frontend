import 'package:flutter/material.dart';
import 'package:garden_homesuit/components/machine_candidate/machine_candidate_card.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/models/machine_candidate.model.dart';
import 'package:garden_homesuit/providers/machine_candidates.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:garden_homesuit/components/common/business_filter.component.dart';
import 'package:garden_homesuit/providers/businesses.provider.dart';
import 'package:garden_homesuit/providers/view_filters.provider.dart';

class MachineCandidatesView extends ConsumerWidget {
  const MachineCandidatesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(machineCandidatesProvider);
    final selectedBusinessIds = ref.watch(candidateBusinessFilterProvider);
    final businessesAsync = ref.watch(businessesProvider);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            onRefresh: () =>
                ref.read(machineCandidatesProvider.notifier).refresh(),
            selectedBusinessIds: selectedBusinessIds,
            onFilterApplied: (ids) =>
                ref.read(candidateBusinessFilterProvider.notifier).state = ids,
          ),
          Expanded(
            child: candidatesAsync.when(
              data: (candidates) {
                return businessesAsync.when(
                  data: (businesses) => _CandidatesList(
                    candidates: candidates,
                    selectedBusinessIds: selectedBusinessIds,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => _ErrorState(error: err),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _ErrorState(error: err),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  final Set<String> selectedBusinessIds;
  final Function(Set<String>) onFilterApplied;

  const _Header({
    required this.onRefresh,
    required this.selectedBusinessIds,
    required this.onFilterApplied,
  });

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
                  Icons.sensors_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Candidatos a Máquinas',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Dispositivos auto-descubiertos',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      BusinessFilter(
                        selectedIds: selectedBusinessIds,
                        onApplied: onFilterApplied,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
            tooltip: 'Refrescar lista',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidatesList extends StatelessWidget {
  final List<MachineCandidate> candidates;
  final Set<String> selectedBusinessIds;

  const _CandidatesList({
    required this.candidates,
    required this.selectedBusinessIds,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Filter
    final filteredCandidates = candidates.where((candidate) {
      if (selectedBusinessIds.isEmpty) return true;
      return selectedBusinessIds.contains(candidate.business);
    }).toList();

    if (filteredCandidates.isEmpty) {
      return const _EmptyState();
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 280,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final candidate = filteredCandidates[index];
              return MachineCandidateCard(
                candidate: candidate,
                onRegister: () {},
              );
            }, childCount: filteredCandidates.length),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_rounded, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No se encontraron candidatos con los filtros aplicados',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.negative),
          const SizedBox(height: 16),
          Text(
            'Error al cargar candidatos: $error',
            style: const TextStyle(color: AppColors.negative),
          ),
        ],
      ),
    );
  }
}
