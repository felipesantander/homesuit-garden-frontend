import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:garden_homesuit/components/machine_candidate/register_machine_form.component.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/providers/machine_candidates.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:garden_homesuit/models/machine_candidate.model.dart';
import 'package:garden_homesuit/providers/data_latest.provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

final registerMachineSaveProvider = StateProvider<VoidCallback?>((ref) => null);
final registerMachineLoadingProvider = StateProvider<bool>((ref) => false);

class RegisterMachineView extends HookConsumerWidget {
  final String serial;

  const RegisterMachineView({super.key, required this.serial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      final saveNotifier = ref.read(registerMachineSaveProvider.notifier);
      final loadingNotifier = ref.read(registerMachineLoadingProvider.notifier);
      return () {
        // Cleanup providers when the entire view is disposed
        Future.microtask(() {
          if (saveNotifier.mounted) {
            saveNotifier.state = null;
          }
          if (loadingNotifier.mounted) {
            loadingNotifier.state = false;
          }
        });
      };
    }, []);

    final candidate = ref.watch(machineCandidateBySerialProvider(serial));
    final formKey = useMemoized(() => GlobalObjectKey(serial));

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Configuración de Nodo',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _AppBarSaveButton(),
            ),
          ],
        ),
        body: SafeArea(
          child: candidate == null
              ? Center(child: _LoadingOrErrorState(serial: serial))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 900;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 1400 : 600,
                          ),
                          child: isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: _ContextPanel(
                                        candidate: candidate,
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    Expanded(
                                      flex: 5,
                                      child: _FormCard(
                                        key: formKey,
                                        candidate: candidate,
                                        onSaved: () => _handleOnSaved(context),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _ContextPanel(candidate: candidate),
                                    const SizedBox(height: 32),
                                    _FormCard(
                                      key: formKey,
                                      candidate: candidate,
                                      onSaved: () => _handleOnSaved(context),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _handleOnSaved(BuildContext context) {
    context.go('/machine-candidates');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nodo de sensores configurado con precisión'),
        backgroundColor: AppColors.positive,
      ),
    );
  }
}

class _AppBarSaveButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSave = ref.watch(registerMachineSaveProvider);
    final isLoading = ref.watch(registerMachineLoadingProvider);

    if (onSave == null) return const SizedBox.shrink();

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.check_rounded, size: 18),
      label: const Text(
        'CONFIGURAR',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ContextPanel extends HookConsumerWidget {
  final MachineCandidate candidate;

  const _ContextPanel({required this.candidate});

  IconData _getIconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('temp')) return Icons.thermostat_rounded;
    if (t.contains('humi')) return Icons.water_drop_rounded;
    if (t.contains('volt')) return Icons.electric_bolt_rounded;
    if (t.contains('press')) return Icons.compress_rounded;
    if (t.contains('light')) return Icons.light_mode_rounded;
    return Icons.sensors_rounded;
  }

  Color _getColorForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('temp')) return Colors.orange;
    if (t.contains('humi')) return Colors.blue;
    if (t.contains('volt')) return Colors.yellow.shade700;
    if (t.contains('light')) return Colors.amber;
    return AppColors.primary;
  }

  String _getLabelForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('temp')) return 'TEMPERATURA';
    if (t.contains('humi')) return 'HUMEDAD';
    if (t.contains('volt')) return 'VOLTAJE';
    if (t.contains('light')) return 'LUMINOSIDAD';
    return type.toUpperCase();
  }

  String _getUnitForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('temp')) return '°C';
    if (t.contains('humi')) return '%';
    if (t.contains('volt')) return 'V';
    if (t.contains('light')) return ' lx';
    if (t.contains('press')) return ' hPa';
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestDataAsync = ref.watch(latestDataProvider(candidate.serial));

    final pulseController = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    useEffect(() {
      pulseController.repeat(reverse: true);
      return null;
    }, [pulseController]);

    final pulseAnimation =
        useAnimation(
          ColorTween(
            begin: AppColors.positive.withValues(alpha: 0.4),
            end: AppColors.positive,
          ).animate(
            CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
          ),
        ) ??
        AppColors.positive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TELEMETRÍA EN VIVO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.invalidate(latestDataProvider(candidate.serial)),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              color: AppColors.primary,
              tooltip: 'Refrescar lectura',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: pulseAnimation,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: pulseAnimation.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'TRANSMITIENDO DATA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.positive,
                    ),
                  ),
                  const Spacer(),
                  latestDataAsync.when(
                    data: (data) {
                      if (data.isEmpty) return const SizedBox.shrink();
                      final firstEntry =
                          data.values.first as Map<String, dynamic>;
                      final rawT = firstEntry['t'] as String?;
                      final rawF = firstEntry['f'] as String?;
                      if (rawT == null) return const SizedBox.shrink();

                      try {
                        final dt = DateTime.parse(rawT).toLocal();
                        final formattedTime = DateFormat('HH:mm:ss').format(dt);
                        final freqText = rawF != null ? ' @ $rawF' : '';

                        return Flexible(
                          child: Text(
                            'LATEST: $formattedTime$freqText',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Fira Code',
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        );
                      } catch (_) {
                        return const SizedBox.shrink();
                      }
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'NÚMERO DE SERIE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                candidate.serial,
                style: const TextStyle(
                  fontFamily: 'Fira Code',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              const Divider(height: 1),
              const SizedBox(height: 24),
              latestDataAsync.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Sin telemetría reciente',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      ...data.entries.map((entry) {
                        final sensorData = entry.value as Map<String, dynamic>;
                        final value = sensorData['v'];
                        final formattedValue = value is num
                            ? value.toStringAsFixed(1)
                            : '$value';
                        final unit = _getUnitForType(entry.key);

                        return _TechnicalIndicator(
                          label: _getLabelForType(entry.key),
                          value: '$formattedValue$unit',
                          icon: _getIconForType(entry.key),
                          color: _getColorForType(entry.key),
                        );
                      }),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Error cargando telemetría',
                      style: TextStyle(fontSize: 12, color: AppColors.negative),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Este nodo está transmitiendo data en tiempo real. Asigne los canales correspondientes para procesar la información.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class _TechnicalIndicator extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TechnicalIndicator({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Fira Code',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final MachineCandidate candidate;
  final VoidCallback onSaved;

  const _FormCard({super.key, required this.candidate, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      color: AppColors.surface.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: RegisterMachineForm(candidate: candidate, onSaved: onSaved),
      ),
    );
  }
}

class _LoadingOrErrorState extends ConsumerWidget {
  final String serial;

  const _LoadingOrErrorState({required this.serial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(machineCandidatesProvider);

    return candidatesAsync.when(
      data: (candidates) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontró el dispositivo con serie:\n$serial',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('VOLVER'),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
