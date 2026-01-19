/// Utility functions to handle timestamps and dates in ISO-8601 UTC format.
library;

String nowIsoUtc() => DateTime.now().toUtc().toIso8601String();

String dateOnly(DateTime dt) => dt.toUtc().toIso8601String().substring(0, 10);
