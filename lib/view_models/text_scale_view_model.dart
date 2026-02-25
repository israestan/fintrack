import 'package:flutter/foundation.dart';

class TextScaleViewModel extends ChangeNotifier {
  double _scale = 1.0;

  double get scale => _scale;

  void setScale(double newScale) {
    if (_scale == newScale) return;
    _scale = newScale;
    notifyListeners();
  }

  /// Convenience setters for the three presets
  // Presets: Small = base (1.0), Medium = 1.5x, Large = 2.0x
  void useSmall() => setScale(1.0);
  void useMedium() => setScale(1.5);
  void useLarge() => setScale(2.0);
}
