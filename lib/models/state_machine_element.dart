import 'dart:ui';

enum StateMachineElementType {
  initialState,
  state,
  finalState,
  transition,
}

class StateMachineElement {
  String id;
  Offset position;
  StateMachineElementType type;
  String label;
  bool isSelected;
  double width;
  double height;
  
  // For transitions
  String? sourceId;
  String? targetId;
  Offset? startPoint;
  Offset? endPoint;
  String? trigger; // Event/condition label

  StateMachineElement({
    required this.id,
    required this.position,
    required this.type,
    this.label = '',
    this.isSelected = false,
    this.width = 120,
    this.height = 60,
    this.sourceId,
    this.targetId,
    this.startPoint,
    this.endPoint,
    this.trigger,
  });

  Rect get bounds => Rect.fromLTWH(
        position.dx,
        position.dy,
        width,
        height,
      );

  bool containsPoint(Offset point) {
    return bounds.contains(point);
  }

  StateMachineElement copyWith({
    String? id,
    Offset? position,
    StateMachineElementType? type,
    String? label,
    bool? isSelected,
    double? width,
    double? height,
    String? sourceId,
    String? targetId,
    Offset? startPoint,
    Offset? endPoint,
    String? trigger,
  }) {
    return StateMachineElement(
      id: id ?? this.id,
      position: position ?? this.position,
      type: type ?? this.type,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
      width: width ?? this.width,
      height: height ?? this.height,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      trigger: trigger ?? this.trigger,
    );
  }
}




