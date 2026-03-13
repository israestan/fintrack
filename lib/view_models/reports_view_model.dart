import 'package:flutter/foundation.dart';

enum ReportPeriod { weekly, monthly, yearly }

class ReportsViewModel extends ChangeNotifier {
  ReportPeriod _period = ReportPeriod.monthly;
  ReportPeriod get period => _period;

  void setPeriod(ReportPeriod p) {
    if (_period == p) return;
    _period = p;
    notifyListeners();
  }

  DateTime get dateFrom {
    final now = DateTime.now();
    switch (_period) {
      case ReportPeriod.weekly:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      case ReportPeriod.monthly:
        return DateTime(now.year, now.month, 1);
      case ReportPeriod.yearly:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime get dateTo {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
}
