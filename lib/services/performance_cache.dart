// Performance optimization: Lazy loading and caching for faster rendering
// Reduces initial load time by deferring expensive operations

import 'dart:ui';
import 'package:flutter/material.dart';

class PerformanceCache {
  static final PerformanceCache _instance = PerformanceCache._internal();
  factory PerformanceCache() => _instance;
  PerformanceCache._internal();
  
  // Cache for expensive paint operations
  final Map<String, ui.Picture> _paintCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration cacheExpiry = Duration(minutes: 5);
  
  // Lazy loading flags
  bool _gridInitialized = false;
  bool _fontsLoaded = false;
  
  // Cache key generator
  String _generateCacheKey(String type, String id, {Map<String, dynamic>? params}) {
    return '$type:$id:${params?.toString() ?? ''}';
  }
  
  // Get cached paint or null
  ui.Picture? getCachedPaint(String type, String id, {Map<String, dynamic>? params}) {
    final key = _generateCacheKey(type, id, params: params);
    final picture = _paintCache[key];
    final timestamp = _cacheTimestamps[key];
    
    if (picture != null && timestamp != null) {
      if (DateTime.now().difference(timestamp) < cacheExpiry) {
        return picture;
      } else {
        // Expired, remove from cache
        _paintCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }
  
  // Cache a paint operation
  void cachePaint(String type, String id, ui.Picture picture, {Map<String, dynamic>? params}) {
    final key = _generateCacheKey(type, id, params: params);
    _paintCache[key] = picture;
    _cacheTimestamps[key] = DateTime.now();
    
    // Limit cache size
    if (_paintCache.length > 100) {
      _evictOldest();
    }
  }
  
  void _evictOldest() {
    if (_cacheTimestamps.isEmpty) return;
    
    var oldestKey = _cacheTimestamps.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
        .key;
    
    _paintCache.remove(oldestKey);
    _cacheTimestamps.remove(oldestKey);
  }
  
  // Lazy initialization helpers
  bool get gridInitialized => _gridInitialized;
  void markGridInitialized() => _gridInitialized = true;
  
  bool get fontsLoaded => _fontsLoaded;
  void markFontsLoaded() => _fontsLoaded = true;
  
  // Clear cache
  void clearCache() {
    _paintCache.clear();
    _cacheTimestamps.clear();
  }
  
  // Preload critical resources (called asynchronously)
  Future<void> preloadResources() async {
    // This can be expanded to preload fonts, images, etc.
    await Future.delayed(const Duration(milliseconds: 100));
    _fontsLoaded = true;
  }
}

