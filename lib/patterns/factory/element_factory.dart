// DESIGN PATTERN: Factory Pattern
// This factory creates different types of UML elements based on the diagram type
// Used in: Element creation throughout the application

import 'dart:ui';
import '../../models/uml_class.dart';
import '../../models/activity_element.dart';
import '../../models/sequence_element.dart';
import '../../models/use_case_element.dart';
import '../../models/state_machine_element.dart';
import '../../models/diagram_type.dart';

abstract class ElementFactory {
  dynamic createElement(String id, Offset position, {Map<String, dynamic>? params});
}

class ClassElementFactory implements ElementFactory {
  @override
  UmlClass createElement(String id, Offset position, {Map<String, dynamic>? params}) {
    return UmlClass(
      id: id,
      position: position,
      className: params?['className'] ?? 'ClassName',
      attributes: params?['attributes'] ?? ['+ attribute1: String'],
      methods: params?['methods'] ?? ['+ method1()'],
      width: params?['width'] ?? 200.0,
      height: params?['height'] ?? 150.0,
    );
  }
}

class ActivityElementFactory implements ElementFactory {
  @override
  ActivityElement createElement(String id, Offset position, {Map<String, dynamic>? params}) {
    final type = params?['type'] as ActivityElementType? ?? ActivityElementType.action;
    return ActivityElement(
      id: id,
      position: position,
      type: type,
      label: params?['label'] ?? (type == ActivityElementType.initialState || type == ActivityElementType.finalState
          ? ''
          : type.toString().split('.').last),
      width: params?['width'] ?? 120.0,
      height: params?['height'] ?? 60.0,
    );
  }
}

class SequenceElementFactory implements ElementFactory {
  @override
  SequenceElement createElement(String id, Offset position, {Map<String, dynamic>? params}) {
    final type = params?['type'] as SequenceElementType? ?? SequenceElementType.actor;
    return SequenceElement(
      id: id,
      position: position,
      type: type,
      label: params?['label'] ?? (type == SequenceElementType.actor ? 'Actor$id' : 'Element$id'),
      lifelineLength: type == SequenceElementType.lifeline ? (params?['lifelineLength'] ?? 300.0) : null,
      width: params?['width'] ?? 100.0,
      height: params?['height'] ?? 150.0,
    );
  }
}

class UseCaseElementFactory implements ElementFactory {
  @override
  UseCaseElement createElement(String id, Offset position, {Map<String, dynamic>? params}) {
    final type = params?['type'] as UseCaseElementType? ?? UseCaseElementType.actor;
    String label = '';
    if (type == UseCaseElementType.actor) {
      label = params?['label'] ?? 'Actor$id';
    } else if (type == UseCaseElementType.useCase) {
      label = params?['label'] ?? 'UseCase$id';
    } else if (type == UseCaseElementType.systemBoundary) {
      label = params?['label'] ?? 'System';
    }
    
    return UseCaseElement(
      id: id,
      position: position,
      type: type,
      label: label,
      description: params?['description'] ?? '',
      width: params?['width'] ?? 120.0,
      height: params?['height'] ?? 60.0,
    );
  }
}

class StateMachineElementFactory implements ElementFactory {
  @override
  StateMachineElement createElement(String id, Offset position, {Map<String, dynamic>? params}) {
    final type = params?['type'] as StateMachineElementType? ?? StateMachineElementType.state;
    return StateMachineElement(
      id: id,
      position: position,
      type: type,
      label: params?['label'] ?? (type == StateMachineElementType.initialState || type == StateMachineElementType.finalState
          ? ''
          : 'State$id'),
      width: params?['width'] ?? 120.0,
      height: params?['height'] ?? 60.0,
    );
  }
}

// Factory Manager - uses Factory Pattern to get the right factory
class ElementFactoryManager {
  static ElementFactory getFactory(DiagramType diagramType) {
    switch (diagramType) {
      case DiagramType.classDiagram:
        return ClassElementFactory();
      case DiagramType.activityDiagram:
        return ActivityElementFactory();
      case DiagramType.sequenceDiagram:
        return SequenceElementFactory();
      case DiagramType.useCaseDiagram:
        return UseCaseElementFactory();
      case DiagramType.stateMachineDiagram:
        return StateMachineElementFactory();
    }
  }
}

