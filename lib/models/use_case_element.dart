import 'dart:ui';

enum UseCaseElementType {
  actor,
  useCase,
  association,
  systemBoundary,
}

class UseCaseElement {
  String id;
  Offset position;
  UseCaseElementType type;
  String label;
  String description; // Functionalities/description for use cases
  bool isSelected;
  double width;
  double height;
  
  // For associations
  String? sourceId;
  String? targetId;
  Offset? startPoint;
  Offset? endPoint;
  
  // For system boundary
  List<String>? useCaseIds;

  UseCaseElement({
    required this.id,
    required this.position,
    required this.type,
    this.label = '',
    this.description = '',
    this.isSelected = false,
    this.width = 120,
    this.height = 60,
    this.sourceId,
    this.targetId,
    this.startPoint,
    this.endPoint,
    this.useCaseIds,
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

  UseCaseElement copyWith({
    String? id,
    Offset? position,
    UseCaseElementType? type,
    String? label,
    String? description,
    bool? isSelected,
    double? width,
    double? height,
    String? sourceId,
    String? targetId,
    Offset? startPoint,
    Offset? endPoint,
    List<String>? useCaseIds,
  }) {
    return UseCaseElement(
      id: id ?? this.id,
      position: position ?? this.position,
      type: type ?? this.type,
      label: label ?? this.label,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
      width: width ?? this.width,
      height: height ?? this.height,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      useCaseIds: useCaseIds ?? this.useCaseIds,
    );
  }
}


