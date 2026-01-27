import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/data/utils/time_utils.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/data/utils/db_helpers.dart';

void main() {
  test('nowIsoUtc returns parseable ISO-8601 UTC string', () {
    final s = nowIsoUtc();
    expect(s, isNotEmpty);
    // Should be parseable by DateTime
    final dt = DateTime.parse(s);
    expect(dt.isUtc, isTrue);
  });

  test('dateOnly returns YYYY-MM-DD', () {
    final sample = DateTime.utc(2025, 12, 28, 15, 30);
    final s = dateOnly(sample);
    expect(s, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    expect(s, '2025-12-28');
  });

  test('generateUuidV4 produces valid UUID string', () {
    final id = generateUuidV4();
    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ),
      ),
    );
  });

  test('withCreateTimestamps adds created_at and updated_at when missing', () {
    final row = <String, Object?>{'name': 'test'};
    final res = withCreateTimestamps(row);
    expect(res.containsKey('created_at'), isTrue);
    expect(res.containsKey('updated_at'), isTrue);
    // values should be parseable
    expect(() => DateTime.parse(res['created_at'] as String), returnsNormally);
    expect(() => DateTime.parse(res['updated_at'] as String), returnsNormally);
  });

  test('withUpdateTimestamp sets updated_at and removes created_at', () {
    final row = <String, Object?>{
      'created_at': '2020-01-01T00:00:00Z',
      'foo': 'bar',
    };
    final res = withUpdateTimestamp(row);
    expect(res.containsKey('created_at'), isFalse);
    expect(res.containsKey('updated_at'), isTrue);
    expect(() => DateTime.parse(res['updated_at'] as String), returnsNormally);
  });
}
