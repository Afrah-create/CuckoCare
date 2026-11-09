import '../../../data_platform/sync/remote_sync_api.dart';
import '../../../data_platform/sync/sync_apply.dart';
import '../../../data_platform/supabase/supabase_bootstrap.dart';

/// Vets are not farm members, so assigned threads arrive through this RPC.
class VetCaseMessageHydrator {
  VetCaseMessageHydrator(this._apply);

  final SyncApply _apply;

  Future<void> pullAssigned({int since = 0}) async {
    final raw = await supabaseClient.rpc(
      'pull_assigned_case_messages',
      params: {'p_since': since},
    );
    final map = Map<String, dynamic>.from(raw as Map);
    final rowsRaw = map['rows'] as List? ?? const [];
    final rows = [
      for (final item in rowsRaw)
        SyncPullRow(
          table: (item as Map)['table'] as String,
          serverVersion: (item['server_version'] as num).toInt(),
          row: Map<String, dynamic>.from(item['row'] as Map),
        ),
    ];
    await _apply.applyPullPage(rows);
  }
}
