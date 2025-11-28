// DESIGN PATTERN: Adapter Pattern
// Adapts different element types to a common interface for unified operations
// Used in: Unified handling of different UML element types

import 'dart:ui';
import '../../models/uml_class.dart';
import '../../models/activity_element.dart';
import '../../models/sequence_element.dart';
import '../../models/use_case_element.dart';
import '../../models/state_machine_element.dart';

// Target interface - what we want to work with
abstract class IElement {
  String get id;
  Offset get position;
  Rect get bounds;
  bool get isSelected;
  bool containsPoint(Offset point);
  dynamic getElement();
}

// Adapters for each element type
class UmlClassAdapter implements IElement {
  final UmlClass _element;
  
  UmlClassAdapter(this._element);
  
  @override
  String get id => _element.id;
  
  @override
  Offset get position => _element.position;
  
  @override
  Rect get bounds => _element.bounds;
  
  @override
  bool get isSelected => _element.isSelected;
  
  @override
  bool containsPoint(Offset point) => _element.containsPoint(point);
  
  @override
  dynamic getElement() => _element;
}

class ActivityElementAdapter implements IElement {
  final ActivityElement _element;
  
  ActivityElementAdapter(this._element);
  
  @override
  String get id => _element.id;
  
  @override
  Offset get position => _element.position;
  
  @override
  Rect get bounds => _element.bounds;
  
  @override
  bool get isSelected => _element.isSelected;
  
  @override
  bool containsPoint(Offset point) => _element.containsPoint(point);
  
  @override
  dynamic getElement() => _element;
}

class SequenceElementAdapter implements IElement {
  final SequenceElement _element;
  
  SequenceElementAdapter(this._element);
  
  @override
  String get id => _element.id;
  
  @override
  Offset get position => _element.position;
  
  @override
  Rect get bounds => _element.bounds;
  
  @override
  bool get isSelected => _element.isSelected;
  
  @override
  bool containsPoint(Offset point) => _element.containsPoint(point);
  
  @override
  dynamic getElement() => _element;
}

class UseCaseElementAdapter implements IElement {
  final UseCaseElement _element;
  
  UseCaseElementAdapter(this._element);
  
  @override
  String get id => _element.id;
  
  @override
  Offset get position => _element.position;
  
  @override
  Rect get bounds => _element.bounds;
  
  @override
  bool get isSelected => _element.isSelected;
  
  @override
  bool containsPoint(Offset point) => _element.containsPoint(point);
  
  @override
  dynamic getElement() => _element;
}

class StateMachineElementAdapter implements IElement {
  final StateMachineElement _element;
  
  StateMachineElementAdapter(this._element);
  
  @override
  String get id => _element.id;
  
  @override
  Offset get position => _element.position;
  
  @override
  Rect get bounds => _element.bounds;
  
  @override
  bool get isSelected => _element.isSelected;
  
  @override
  bool containsPoint(Offset point) => _element.containsPoint(point);
  
  @override
  dynamic getElement() => _element;
}

// Factory for creating adapters
class ElementAdapterFactory {
  static IElement createAdapter(dynamic element) {
    if (element is UmlClass) {
      return UmlClassAdapter(element);
    } else if (element is ActivityElement) {
      return ActivityElementAdapter(element);
    } else if (element is SequenceElement) {
      return SequenceElementAdapter(element);
    } else if (element is UseCaseElement) {
      return UseCaseElementAdapter(element);
    } else if (element is StateMachineElement) {
      return StateMachineElementAdapter(element);
    }
    throw ArgumentError('Unknown element type');
  }
}

