// DESIGN PATTERN: State Pattern
// Allows an object to alter its behavior when its internal state changes
// Used in: Managing different interaction modes (select, drag, resize, edit)

abstract class DiagramState {
  void handlePanStart(DragStartDetails details, DiagramContext context);
  void handlePanUpdate(DragUpdateDetails details, DiagramContext context);
  void handlePanEnd(DragEndDetails details, DiagramContext context);
  void handleTap(Offset position, DiagramContext context);
}

class DiagramContext {
  dynamic selectedElement;
  dynamic draggingElement;
  Offset? dragOffset;
  String stateType = 'idle';
  
  void changeState(DiagramState newState) {
    // State change logic
  }
}

// Concrete states
class IdleState implements DiagramState {
  @override
  void handlePanStart(DragStartDetails details, DiagramContext context) {
    // Transition to select or drag state
  }
  
  @override
  void handlePanUpdate(DragUpdateDetails details, DiagramContext context) {
    // No action in idle
  }
  
  @override
  void handlePanEnd(DragEndDetails details, DiagramContext context) {
    // No action in idle
  }
  
  @override
  void handleTap(Offset position, DiagramContext context) {
    // Handle selection
  }
}

class SelectState implements DiagramState {
  @override
  void handlePanStart(DragStartDetails details, DiagramContext context) {
    // Transition to drag state
  }
  
  @override
  void handlePanUpdate(DragUpdateDetails details, DiagramContext context) {
    // Transition to drag if movement detected
  }
  
  @override
  void handlePanEnd(DragEndDetails details, DiagramContext context) {
    // Return to idle
  }
  
  @override
  void handleTap(Offset position, DiagramContext context) {
    // Handle selection change
  }
}

class DragState implements DiagramState {
  @override
  void handlePanStart(DragStartDetails details, DiagramContext context) {
    // Continue dragging
  }
  
  @override
  void handlePanUpdate(DragUpdateDetails details, DiagramContext context) {
    // Update element position
  }
  
  @override
  void handlePanEnd(DragEndDetails details, DiagramContext context) {
    // Return to select or idle
  }
  
  @override
  void handleTap(Offset position, DiagramContext context) {
    // Cancel drag, transition to select
  }
}

class ResizeState implements DiagramState {
  @override
  void handlePanStart(DragStartDetails details, DiagramContext context) {
    // Continue resizing
  }
  
  @override
  void handlePanUpdate(DragUpdateDetails details, DiagramContext context) {
    // Update element size
  }
  
  @override
  void handlePanEnd(DragEndDetails details, DiagramContext context) {
    // Return to select
  }
  
  @override
  void handleTap(Offset position, DiagramContext context) {
    // Cancel resize, transition to select
  }
}

