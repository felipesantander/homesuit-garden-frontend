import 'package:garden_homesuit/models/data_query_filter.model.dart';
import 'package:garden_homesuit/providers/data_latest.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final dataQueryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, DataQueryFilter>((
      ref,
      filter,
    ) async {
      final service = ref.read(dataServiceProvider);

      return service.query(
        machineId: filter.machineId,
        channels: filter.channels.isNotEmpty ? filter.channels.join(',') : null,
        start: filter.start,
        end: filter.end,
        f: filter.frequency,
        limit: 300, // Reasonable limit for details view charts/tables
      );
    });
