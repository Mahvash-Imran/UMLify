// DESIGN PATTERN: Composite Pattern
// Composes objects into tree structures to represent part-whole hierarchies
// Used in: Grouping elements together, managing collections of elements

import 'dart:ui';
import '../adapter/element_adapter.dart';

abstract class DiagramComponent {
  String get id;
  Rect get bounds;
  void render();
  void move(Offset delta);
  bool containsPoint(Offset point);
  List<DiagramComponent> getChildren();
}

// Leaf - represents individual elements
class ElementLeaf implements DiagramComponent {
  final IElement _element;
  
  ElementLeaf(this._element);
  
  @override
  String get id => _element.id;
  
  @override
  Rect get bounds => _element.bounds;
  
  @override
  void render() {
    // Rendering handled by canvas painter
  }
  
  @override
  void move(Offset delta) {
    // Move logic handled by element update callbacks
  }
  
  @override
  bool containsPoint(Offset point) => _element.containsPoint(point);
  
  @override
  List<DiagramComponent> getChildren() => [];
  
  IElement get element => _element;
}

// Composite - represents a group of elements
class ElementGroup implements DiagramComponent {
  final String _id;
  final List<DiagramComponent> _children = [];
  
  ElementGroup(this._id);
  
  void add(DiagramComponent component) {
    _children.add(component);
  }
  
  void remove(DiagramComponent component) {
    _children.remove(component);
  }
  
  @override
  String get id => _id;
  
  @override
  Rect get bounds {
    if (_children.isEmpty) return Rect.zero;
    
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    
    for (var child in _children) {
      final bounds = child.bounds;
      minX = minX < bounds.left ? minX : bounds.left;
      minY = minY < bounds.top ? minY : bounds.top;
      maxX = maxX > bounds.right ? maxX : bounds.right;
      maxY = maxY > bounds.bottom ? maxY : bounds.bottom;
    }
    
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
  
  @override
  void render() {
    for (var child in _children) {
      child.render();
    }
  }
  
  @override
  void move(Offset delta) {
    for (var child in _children) {
      child.move(delta);
    }
  }
  
  @override
  bool containsPoint(Offset point) {
    for (var child in _children) {
      if (child.containsPoint(point)) {
        return true;
      }
    }
    return false;
  }
  
  @override
  List<DiagramComponent> getChildren() => List.from(_children);
}

