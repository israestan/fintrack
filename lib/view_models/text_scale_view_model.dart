import 'package:flutter/foundation.dart';

class TextScaleViewModel extends ChangeNotifier {
  double _scale = 1.0;

  double get scale => _scale;

  void setScale(double newScale) {
    if (_scale == newScale) return;
    _scale = newScale;
    notifyListeners();
  }

  void useSmall() => setScale(1.0);
  void useMedium() => setScale(1.5);
  void useLarge() => setScale(2.0);
}
