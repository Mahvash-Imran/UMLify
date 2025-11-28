import 'dart:ui';

enum ActivityElementType {
  initialState,
  action,
  decision,
  fork,
  join,
  finalState,
  flow,
}

class ActivityElement {
  String id;
  Offset position;
  ActivityElementType type;
  String label;
  bool isSelected;
  double width;
  double height;
  
  // For flows (arrows)
  String? sourceId;
  String? targetId;
  Offset? startPoint;
  Offset? endPoint;

  ActivityElement({
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

  ActivityElement copyWith({
    String? id,
    Offset? position,
    ActivityElementType? type,
    String? label,
    bool? isSelected,
    double? width,
    double? height,
    String? sourceId,
    String? targetId,
    Offset? startPoint,
    Offset? endPoint,
  }) {
    return ActivityElement(
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
    );
  }
}




