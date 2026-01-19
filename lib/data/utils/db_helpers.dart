import 'time_utils.dart';

/// Apply create timestamps for rows before insert.
Map<String, Object?> withCreateTimestamps(Map<String, Object?> row) {
  final now = nowIsoUtc();
  final result = Map<String, Object?>.from(row);
  result['created_at'] ??= now;
  result['updated_at'] ??= now;
  return result;
}

/// Apply update timestamp for rows before update.
/// Removes `created_at` to avoid accidental modification.
Map<String, Object?> withUpdateTimestamp(Map<String, Object?> row) {
  final now = nowIsoUtc();
  final result = Map<String, Object?>.from(row);
  result['updated_at'] = now;
  result.remove('created_at');
  return result;
}
