import 'dart:ui';

enum SequenceElementType {
  actor,
  lifeline,
  message,
  activationBar,
}

class SequenceElement {
  String id;
  Offset position;
  SequenceElementType type;
  String label;
  bool isSelected;
  double width;
  double height;
  
  // For messages
  String? sourceId;
  String? targetId;
  Offset? startPoint;
  Offset? endPoint;
  String? messageType; // 'sync', 'async', 'return'
  
  // For lifelines
  double? lifelineLength;

  SequenceElement({
    required this.id,
    required this.position,
    required this.type,
    this.label = '',
    this.isSelected = false,
    this.width = 100,
    this.height = 150,
    this.sourceId,
    this.targetId,
    this.startPoint,
    this.endPoint,
    this.messageType,
    this.lifelineLength,
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

  SequenceElement copyWith({
    String? id,
    Offset? position,
    SequenceElementType? type,
    String? label,
    bool? isSelected,
    double? width,
    double? height,
    String? sourceId,
    String? targetId,
    Offset? startPoint,
    Offset? endPoint,
    String? messageType,
    double? lifelineLength,
  }) {
    return SequenceElement(
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
      messageType: messageType ?? this.messageType,
      lifelineLength: lifelineLength ?? this.lifelineLength,
    );
  }
}


