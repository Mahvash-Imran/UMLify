// DESIGN PATTERN: Singleton Pattern
// This singleton manages application-wide configuration and settings
// Used in: Global configuration, default values, app-wide state

class AppConfig {
  static AppConfig? _instance;
  
  // Private constructor
  AppConfig._internal() {
    _gridSize = 20.0;
    _defaultElementWidth = 120.0;
    _defaultElementHeight = 60.0;
    _defaultClassWidth = 200.0;
    _defaultClassHeight = 150.0;
    _canvasWidth = 2000.0;
    _canvasHeight = 2000.0;
    _minScale = 0.1;
    _maxScale = 4.0;
    _enableCaching = true;
  }
  
  // Factory constructor to ensure only one instance
  factory AppConfig() {
    _instance ??= AppConfig._internal();
    return _instance!;
  }
  
  // Configuration properties
  double _gridSize;
  double _defaultElementWidth;
  double _defaultElementHeight;
  double _defaultClassWidth;
  double _defaultClassHeight;
  double _canvasWidth;
  double _canvasHeight;
  double _minScale;
  double _maxScale;
  bool _enableCaching;
  
  // Getters
  double get gridSize => _gridSize;
  double get defaultElementWidth => _defaultElementWidth;
  double get defaultElementHeight => _defaultElementHeight;
  double get defaultClassWidth => _defaultClassWidth;
  double get defaultClassHeight => _defaultClassHeight;
  double get canvasWidth => _canvasWidth;
  double get canvasHeight => _canvasHeight;
  double get minScale => _minScale;
  double get maxScale => _maxScale;
  bool get enableCaching => _enableCaching;
  
  // Setters
  void setGridSize(double size) => _gridSize = size;
  void setDefaultElementWidth(double width) => _defaultElementWidth = width;
  void setDefaultElementHeight(double height) => _defaultElementHeight = height;
  void setEnableCaching(bool enable) => _enableCaching = enable;
}

