import 'dart:ui';

class UmlClass {
  String id;
  Offset position;
  double width;
  double height;
  String className;
  List<String> attributes;
  List<String> methods;
  bool isSelected;

  UmlClass({
    required this.id,
    required this.position,
    this.width = 200,
    this.height = 150,
    this.className = 'ClassName',
    List<String>? attributes,
    List<String>? methods,
    this.isSelected = false,
  })  : attributes = attributes ?? [],
        methods = methods ?? [];

  Rect get bounds => Rect.fromLTWH(
        position.dx,
        position.dy,
        width,
        height,
      );

  bool containsPoint(Offset point) {
    return bounds.contains(point);
  }

  UmlClass copyWith({
    String? id,
    Offset? position,
    double? width,
    double? height,
    String? className,
    List<String>? attributes,
    List<String>? methods,
    bool? isSelected,
  }) {
    return UmlClass(
      id: id ?? this.id,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      className: className ?? this.className,
      attributes: attributes ?? List.from(this.attributes),
      methods: methods ?? List.from(this.methods),
      isSelected: isSelected ?? this.isSelected,
    );
  }
}



