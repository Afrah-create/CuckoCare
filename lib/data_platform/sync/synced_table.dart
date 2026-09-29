enum SyncTableKind { mutable, appendOnly, reference }

abstract class SyncedTable<T> {
  String get tableName;
  SyncTableKind get kind;
  String scopeForRow(T row);

  Map<String, dynamic> toPayload(T row);
  T fromRemote(Map<String, dynamic> json);
}
