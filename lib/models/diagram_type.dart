enum DiagramType {
  classDiagram,
  activityDiagram,
  sequenceDiagram,
  useCaseDiagram,
  stateMachineDiagram,
}

extension DiagramTypeExtension on DiagramType {
  String get displayName {
    switch (this) {
      case DiagramType.classDiagram:
        return 'Class Diagram';
      case DiagramType.activityDiagram:
        return 'Activity Diagram';
      case DiagramType.sequenceDiagram:
        return 'Sequence Diagram';
      case DiagramType.useCaseDiagram:
        return 'Use Case Diagram';
      case DiagramType.stateMachineDiagram:
        return 'State Machine Diagram';
    }
  }
}




