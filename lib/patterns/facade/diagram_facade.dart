// DESIGN PATTERN: Facade Pattern
// Provides a simplified interface to a complex subsystem
// Used in: Simplifying diagram operations like save, load, export

import 'dart:ui';
import '../../services/image_saver.dart';
import '../../models/diagram_type.dart';
import '../../models/uml_class.dart';
import '../../models/activity_element.dart';
import '../../models/sequence_element.dart';
import '../../models/use_case_element.dart';
import '../../models/state_machine_element.dart';

class DiagramFacade {
  // Facade for saving operations
  static Future<String?> saveDiagram(
    GlobalKey repaintBoundaryKey, {
    bool toGallery = true,
  }) async {
    if (toGallery) {
      return await ImageSaver.saveAsPng(repaintBoundaryKey);
    } else {
      return await ImageSaver.saveToFile(repaintBoundaryKey);
    }
  }
  
  // Facade for diagram state management
  static Map<String, dynamic> exportDiagramState({
    required DiagramType diagramType,
    List<UmlClass>? classes,
    List<ActivityElement>? activityElements,
    List<SequenceElement>? sequenceElements,
    List<UseCaseElement>? useCaseElements,
    List<StateMachineElement>? stateMachineElements,
  }) {
    return {
      'diagramType': diagramType.toString(),
      'classes': classes?.map((c) => _classToMap(c)).toList(),
      'activityElements': activityElements?.map((e) => _activityToMap(e)).toList(),
      'sequenceElements': sequenceElements?.map((e) => _sequenceToMap(e)).toList(),
      'useCaseElements': useCaseElements?.map((e) => _useCaseToMap(e)).toList(),
      'stateMachineElements': stateMachineElements?.map((e) => _stateMachineToMap(e)).toList(),
    };
  }
  
  // Helper methods for serialization
  static Map<String, dynamic> _classToMap(UmlClass c) {
    return {
      'id': c.id,
      'position': {'dx': c.position.dx, 'dy': c.position.dy},
      'width': c.width,
      'height': c.height,
      'className': c.className,
      'attributes': c.attributes,
      'methods': c.methods,
    };
  }
  
  static Map<String, dynamic> _activityToMap(ActivityElement e) {
    return {
      'id': e.id,
      'position': {'dx': e.position.dx, 'dy': e.position.dy},
      'type': e.type.toString(),
      'label': e.label,
      'width': e.width,
      'height': e.height,
    };
  }
  
  static Map<String, dynamic> _sequenceToMap(SequenceElement e) {
    return {
      'id': e.id,
      'position': {'dx': e.position.dx, 'dy': e.position.dy},
      'type': e.type.toString(),
      'label': e.label,
      'width': e.width,
      'height': e.height,
      'lifelineLength': e.lifelineLength,
    };
  }
  
  static Map<String, dynamic> _useCaseToMap(UseCaseElement e) {
    return {
      'id': e.id,
      'position': {'dx': e.position.dx, 'dy': e.position.dy},
      'type': e.type.toString(),
      'label': e.label,
      'description': e.description,
      'width': e.width,
      'height': e.height,
    };
  }
  
  static Map<String, dynamic> _stateMachineToMap(StateMachineElement e) {
    return {
      'id': e.id,
      'position': {'dx': e.position.dx, 'dy': e.position.dy},
      'type': e.type.toString(),
      'label': e.label,
      'width': e.width,
      'height': e.height,
      'trigger': e.trigger,
    };
  }
}

