import 'package:flutter/material.dart';
import '../data/db/fintrack_db.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initializeApp() async {
    await FinTrackDb.instance.init();

    await Future.delayed(
      const Duration(seconds: 2),
    );

    _isInitialized = true;
    notifyListeners();
  }
}
