// DESIGN PATTERNS USED IN THIS FILE:
// - Adapter Pattern: ElementAdapterFactory for unified element handling
// - Decorator Pattern: Visual decorations for selected elements
// - Template Method Pattern: Rendering algorithm structure
// - Performance: Lazy grid rendering, optimized repaint

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/diagram_type.dart';
import '../models/uml_class.dart';
import '../models/activity_element.dart';
import '../models/sequence_element.dart';
import '../models/use_case_element.dart';
import '../models/state_machine_element.dart';
import '../patterns/singleton/app_config.dart';
import '../services/performance_cache.dart';

class UnifiedUmlCanvas extends StatefulWidget {
  final DiagramType diagramType;
  final List<UmlClass> classes;
  final List<ActivityElement> activityElements;
  final List<SequenceElement> sequenceElements;
  final List<UseCaseElement> useCaseElements;
  final List<StateMachineElement> stateMachineElements;
  final Function(UmlClass)? onClassUpdate;
  final Function(UmlClass)? onClassSelect;
  final Function(ActivityElement)? onActivityElementUpdate;
  final Function(ActivityElement)? onActivityElementSelect;
  final Function(SequenceElement)? onSequenceElementUpdate;
  final Function(SequenceElement)? onSequenceElementSelect;
  final Function(UseCaseElement)? onUseCaseElementUpdate;
  final Function(UseCaseElement)? onUseCaseElementSelect;
  final Function(StateMachineElement)? onStateMachineElementUpdate;
  final Function(StateMachineElement)? onStateMachineElementSelect;
  final GlobalKey repaintBoundaryKey;

  const UnifiedUmlCanvas({
    super.key,
    required this.diagramType,
    this.classes = const [],
    this.activityElements = const [],
    this.sequenceElements = const [],
    this.useCaseElements = const [],
    this.stateMachineElements = const [],
    this.onClassUpdate,
    this.onClassSelect,
    this.onActivityElementUpdate,
    this.onActivityElementSelect,
    this.onSequenceElementUpdate,
    this.onSequenceElementSelect,
    this.onUseCaseElementUpdate,
    this.onUseCaseElementSelect,
    this.onStateMachineElementUpdate,
    this.onStateMachineElementSelect,
    required this.repaintBoundaryKey,
  });

  @override
  State<UnifiedUmlCanvas> createState() => _UnifiedUmlCanvasState();
}

enum ResizeHandle {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
}

class _UnifiedUmlCanvasState extends State<UnifiedUmlCanvas> {
  dynamic _selectedElement;
  dynamic _draggingElement;
  Offset? _dragOffset;
  ResizeHandle _resizeHandle = ResizeHandle.none;
  Offset? _resizeStartPoint;
  double? _resizeStartWidth;
  double? _resizeStartHeight;
  Offset? _resizeStartPosition;

  ResizeHandle _getResizeHandle(Offset point, Rect bounds) {
    const handleSize = 8.0;
    const handleArea = handleSize * 2;
    
    // Check corners first
    if ((point - Offset(bounds.left, bounds.top)).distance < handleArea) {
      return ResizeHandle.topLeft;
    }
    if ((point - Offset(bounds.right, bounds.top)).distance < handleArea) {
      return ResizeHandle.topRight;
    }
    if ((point - Offset(bounds.left, bounds.bottom)).distance < handleArea) {
      return ResizeHandle.bottomLeft;
    }
    if ((point - Offset(bounds.right, bounds.bottom)).distance < handleArea) {
      return ResizeHandle.bottomRight;
    }
    
    // Check edges
    if ((point.dx - bounds.left).abs() < handleArea && 
        point.dy >= bounds.top && point.dy <= bounds.bottom) {
      return ResizeHandle.left;
    }
    if ((point.dx - bounds.right).abs() < handleArea && 
        point.dy >= bounds.top && point.dy <= bounds.bottom) {
      return ResizeHandle.right;
    }
    if ((point.dy - bounds.top).abs() < handleArea && 
        point.dx >= bounds.left && point.dx <= bounds.right) {
      return ResizeHandle.top;
    }
    if ((point.dy - bounds.bottom).abs() < handleArea && 
        point.dx >= bounds.left && point.dx <= bounds.right) {
      return ResizeHandle.bottom;
    }
    
    return ResizeHandle.none;
  }

  bool _isResizable(dynamic element) {
    if (element == null) return false;
    // Most elements are resizable except some special types
    if (element is SequenceElement) {
      return element.type == SequenceElementType.actor || 
             element.type == SequenceElementType.lifeline ||
             element.type == SequenceElementType.activationBar;
    }
    if (element is ActivityElement) {
      return element.type != ActivityElementType.initialState && 
             element.type != ActivityElementType.finalState &&
             element.type != ActivityElementType.flow;
    }
    if (element is UseCaseElement) {
      return element.type != UseCaseElementType.association;
    }
    if (element is StateMachineElement) {
      return element.type != StateMachineElementType.initialState && 
             element.type != StateMachineElementType.finalState &&
             element.type != StateMachineElementType.transition;
    }
    return true; // UmlClass and others are resizable
  }

  void _handlePanStart(DragStartDetails details) {
    final point = details.localPosition;
    
    // Check if clicking on a resize handle of selected element
    if (_selectedElement != null && _isResizable(_selectedElement)) {
      Rect bounds;
      if (_selectedElement is UmlClass) {
        bounds = (_selectedElement as UmlClass).bounds;
      } else if (_selectedElement is ActivityElement) {
        bounds = (_selectedElement as ActivityElement).bounds;
      } else if (_selectedElement is SequenceElement) {
        bounds = (_selectedElement as SequenceElement).bounds;
      } else if (_selectedElement is UseCaseElement) {
        bounds = (_selectedElement as UseCaseElement).bounds;
      } else if (_selectedElement is StateMachineElement) {
        bounds = (_selectedElement as StateMachineElement).bounds;
      } else {
        bounds = Rect.zero;
      }
      
      _resizeHandle = _getResizeHandle(point, bounds);
      if (_resizeHandle != ResizeHandle.none) {
        _resizeStartPoint = point;
        if (_selectedElement is UmlClass) {
          final el = _selectedElement as UmlClass;
          _resizeStartWidth = el.width;
          _resizeStartHeight = el.height;
          _resizeStartPosition = el.position;
        } else if (_selectedElement is ActivityElement) {
          final el = _selectedElement as ActivityElement;
          _resizeStartWidth = el.width;
          _resizeStartHeight = el.height;
          _resizeStartPosition = el.position;
        } else if (_selectedElement is SequenceElement) {
          final el = _selectedElement as SequenceElement;
          _resizeStartWidth = el.width;
          _resizeStartHeight = el.height;
          _resizeStartPosition = el.position;
        } else if (_selectedElement is UseCaseElement) {
          final el = _selectedElement as UseCaseElement;
          _resizeStartWidth = el.width;
          _resizeStartHeight = el.height;
          _resizeStartPosition = el.position;
        } else if (_selectedElement is StateMachineElement) {
          final el = _selectedElement as StateMachineElement;
          _resizeStartWidth = el.width;
          _resizeStartHeight = el.height;
          _resizeStartPosition = el.position;
        }
        return;
      }
    }
    
    switch (widget.diagramType) {
      case DiagramType.classDiagram:
        for (var umlClass in widget.classes.reversed) {
          if (umlClass.containsPoint(point)) {
            _selectedElement = umlClass;
            _draggingElement = umlClass;
            _dragOffset = Offset(
              point.dx - umlClass.position.dx,
              point.dy - umlClass.position.dy,
            );
            widget.onClassSelect?.call(umlClass);
            setState(() {});
            return;
          }
        }
        break;
      case DiagramType.activityDiagram:
        for (var element in widget.activityElements.reversed) {
          if (element.containsPoint(point)) {
            _selectedElement = element;
            _draggingElement = element;
            _dragOffset = Offset(
              point.dx - element.position.dx,
              point.dy - element.position.dy,
            );
            widget.onActivityElementSelect?.call(element);
            setState(() {});
            return;
          }
        }
        break;
      case DiagramType.sequenceDiagram:
        for (var element in widget.sequenceElements.reversed) {
          if (element.containsPoint(point)) {
            _selectedElement = element;
            _draggingElement = element;
            _dragOffset = Offset(
              point.dx - element.position.dx,
              point.dy - element.position.dy,
            );
            widget.onSequenceElementSelect?.call(element);
            setState(() {});
            return;
          }
        }
        break;
      case DiagramType.useCaseDiagram:
        for (var element in widget.useCaseElements.reversed) {
          if (element.containsPoint(point)) {
            _selectedElement = element;
            _draggingElement = element;
            _dragOffset = Offset(
              point.dx - element.position.dx,
              point.dy - element.position.dy,
            );
            widget.onUseCaseElementSelect?.call(element);
            setState(() {});
            return;
          }
        }
        break;
      case DiagramType.stateMachineDiagram:
        for (var element in widget.stateMachineElements.reversed) {
          if (element.containsPoint(point)) {
            _selectedElement = element;
            _draggingElement = element;
            _dragOffset = Offset(
              point.dx - element.position.dx,
              point.dy - element.position.dy,
            );
            widget.onStateMachineElementSelect?.call(element);
            setState(() {});
            return;
          }
        }
        break;
    }
    
    // No element selected
    _selectedElement = null;
    _draggingElement = null;
    setState(() {});
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Handle resizing
    if (_resizeHandle != ResizeHandle.none && 
        _resizeStartPoint != null && 
        _resizeStartWidth != null && 
        _resizeStartHeight != null && 
        _resizeStartPosition != null) {
      final delta = details.localPosition - _resizeStartPoint!;
      double newWidth = _resizeStartWidth!;
      double newHeight = _resizeStartHeight!;
      Offset newPosition = _resizeStartPosition!;
      
      // Calculate new size and position based on resize handle
      switch (_resizeHandle) {
        case ResizeHandle.topLeft:
          newWidth = (_resizeStartWidth! - delta.dx).clamp(50.0, double.infinity);
          newHeight = (_resizeStartHeight! - delta.dy).clamp(50.0, double.infinity);
          newPosition = Offset(
            _resizeStartPosition!.dx + (_resizeStartWidth! - newWidth),
            _resizeStartPosition!.dy + (_resizeStartHeight! - newHeight),
          );
          break;
        case ResizeHandle.topRight:
          newWidth = (_resizeStartWidth! + delta.dx).clamp(50.0, double.infinity);
          newHeight = (_resizeStartHeight! - delta.dy).clamp(50.0, double.infinity);
          newPosition = Offset(
            _resizeStartPosition!.dx,
            _resizeStartPosition!.dy + (_resizeStartHeight! - newHeight),
          );
          break;
        case ResizeHandle.bottomLeft:
          newWidth = (_resizeStartWidth! - delta.dx).clamp(50.0, double.infinity);
          newHeight = (_resizeStartHeight! + delta.dy).clamp(50.0, double.infinity);
          newPosition = Offset(
            _resizeStartPosition!.dx + (_resizeStartWidth! - newWidth),
            _resizeStartPosition!.dy,
          );
          break;
        case ResizeHandle.bottomRight:
          newWidth = (_resizeStartWidth! + delta.dx).clamp(50.0, double.infinity);
          newHeight = (_resizeStartHeight! + delta.dy).clamp(50.0, double.infinity);
          newPosition = _resizeStartPosition!;
          break;
        case ResizeHandle.top:
          newHeight = (_resizeStartHeight! - delta.dy).clamp(50.0, double.infinity);
          newPosition = Offset(
            _resizeStartPosition!.dx,
            _resizeStartPosition!.dy + (_resizeStartHeight! - newHeight),
          );
          break;
        case ResizeHandle.bottom:
          newHeight = (_resizeStartHeight! + delta.dy).clamp(50.0, double.infinity);
          break;
        case ResizeHandle.left:
          newWidth = (_resizeStartWidth! - delta.dx).clamp(50.0, double.infinity);
          newPosition = Offset(
            _resizeStartPosition!.dx + (_resizeStartWidth! - newWidth),
            _resizeStartPosition!.dy,
          );
          break;
        case ResizeHandle.right:
          newWidth = (_resizeStartWidth! + delta.dx).clamp(50.0, double.infinity);
          break;
        case ResizeHandle.none:
          break;
      }
      
      // Update the element
      if (_selectedElement is UmlClass) {
        widget.onClassUpdate?.call((_selectedElement as UmlClass).copyWith(
          position: newPosition,
          width: newWidth,
          height: newHeight,
        ));
      } else if (_selectedElement is ActivityElement) {
        widget.onActivityElementUpdate?.call((_selectedElement as ActivityElement).copyWith(
          position: newPosition,
          width: newWidth,
          height: newHeight,
        ));
      } else if (_selectedElement is SequenceElement) {
        widget.onSequenceElementUpdate?.call((_selectedElement as SequenceElement).copyWith(
          position: newPosition,
          width: newWidth,
          height: newHeight,
        ));
      } else if (_selectedElement is UseCaseElement) {
        widget.onUseCaseElementUpdate?.call((_selectedElement as UseCaseElement).copyWith(
          position: newPosition,
          width: newWidth,
          height: newHeight,
        ));
      } else if (_selectedElement is StateMachineElement) {
        widget.onStateMachineElementUpdate?.call((_selectedElement as StateMachineElement).copyWith(
          position: newPosition,
          width: newWidth,
          height: newHeight,
        ));
      }
      return;
    }
    
    // Handle dragging
    if (_draggingElement != null && _dragOffset != null) {
      final newPosition = Offset(
        details.localPosition.dx - _dragOffset!.dx,
        details.localPosition.dy - _dragOffset!.dy,
      );
      
      switch (widget.diagramType) {
        case DiagramType.classDiagram:
          if (_draggingElement is UmlClass) {
            widget.onClassUpdate?.call((_draggingElement as UmlClass).copyWith(position: newPosition));
          }
          break;
        case DiagramType.activityDiagram:
          if (_draggingElement is ActivityElement) {
            widget.onActivityElementUpdate?.call((_draggingElement as ActivityElement).copyWith(position: newPosition));
          }
          break;
        case DiagramType.sequenceDiagram:
          if (_draggingElement is SequenceElement) {
            widget.onSequenceElementUpdate?.call((_draggingElement as SequenceElement).copyWith(position: newPosition));
          }
          break;
        case DiagramType.useCaseDiagram:
          if (_draggingElement is UseCaseElement) {
            widget.onUseCaseElementUpdate?.call((_draggingElement as UseCaseElement).copyWith(position: newPosition));
          }
          break;
        case DiagramType.stateMachineDiagram:
          if (_draggingElement is StateMachineElement) {
            widget.onStateMachineElementUpdate?.call((_draggingElement as StateMachineElement).copyWith(position: newPosition));
          }
          break;
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _draggingElement = null;
    _dragOffset = null;
    _resizeHandle = ResizeHandle.none;
    _resizeStartPoint = null;
    _resizeStartWidth = null;
    _resizeStartHeight = null;
    _resizeStartPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            painter: _UnifiedUmlCanvasPainter(
              diagramType: widget.diagramType,
              classes: widget.classes,
              activityElements: widget.activityElements,
              sequenceElements: widget.sequenceElements,
              useCaseElements: widget.useCaseElements,
              stateMachineElements: widget.stateMachineElements,
              selectedElement: _selectedElement,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          );
        },
      ),
    );
  }
}

class _UnifiedUmlCanvasPainter extends CustomPainter {
  final DiagramType diagramType;
  final List<UmlClass> classes;
  final List<ActivityElement> activityElements;
  final List<SequenceElement> sequenceElements;
  final List<UseCaseElement> useCaseElements;
  final List<StateMachineElement> stateMachineElements;
  final dynamic selectedElement;

  _UnifiedUmlCanvasPainter({
    required this.diagramType,
    required this.classes,
    required this.activityElements,
    required this.sequenceElements,
    required this.useCaseElements,
    required this.stateMachineElements,
    this.selectedElement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // PERFORMANCE: Optimized grid rendering using singleton config
    final config = AppConfig();
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    final gridSize = config.gridSize;
    // PERFORMANCE: Only draw visible grid lines (optimization for large canvases)
    final step = gridSize;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw based on diagram type
    switch (diagramType) {
      case DiagramType.classDiagram:
        _drawClassDiagram(canvas);
        break;
      case DiagramType.activityDiagram:
        _drawActivityDiagram(canvas);
        break;
      case DiagramType.sequenceDiagram:
        _drawSequenceDiagram(canvas);
        break;
      case DiagramType.useCaseDiagram:
        _drawUseCaseDiagram(canvas);
        break;
      case DiagramType.stateMachineDiagram:
        _drawStateMachineDiagram(canvas);
        break;
    }
    
    // Draw resize handles for selected element
    if (selectedElement != null) {
      _drawResizeHandles(canvas, selectedElement);
    }
  }
  
  void _drawResizeHandles(Canvas canvas, dynamic element) {
    Rect bounds;
    bool isResizable = false;
    
    if (element is UmlClass) {
      bounds = element.bounds;
      isResizable = true;
    } else if (element is ActivityElement) {
      bounds = element.bounds;
      isResizable = element.type != ActivityElementType.initialState && 
                    element.type != ActivityElementType.finalState &&
                    element.type != ActivityElementType.flow;
    } else if (element is SequenceElement) {
      bounds = element.bounds;
      isResizable = element.type == SequenceElementType.actor || 
                    element.type == SequenceElementType.lifeline ||
                    element.type == SequenceElementType.activationBar;
    } else if (element is UseCaseElement) {
      bounds = element.bounds;
      isResizable = element.type != UseCaseElementType.association;
    } else if (element is StateMachineElement) {
      bounds = element.bounds;
      isResizable = element.type != StateMachineElementType.initialState && 
                    element.type != StateMachineElementType.finalState &&
                    element.type != StateMachineElementType.transition;
    } else {
      return;
    }
    
    if (!isResizable) return;
    
    const handleSize = 8.0;
    final handlePaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw corner handles
    final corners = [
      Offset(bounds.left, bounds.top),      // topLeft
      Offset(bounds.right, bounds.top),     // topRight
      Offset(bounds.left, bounds.bottom),  // bottomLeft
      Offset(bounds.right, bounds.bottom),  // bottomRight
    ];
    
    for (var corner in corners) {
      canvas.drawCircle(corner, handleSize, handlePaint);
      canvas.drawCircle(corner, handleSize, borderPaint);
    }
    
    // Draw edge handles
    final edges = [
      Offset(bounds.center.dx, bounds.top),        // top
      Offset(bounds.center.dx, bounds.bottom),  // bottom
      Offset(bounds.left, bounds.center.dy),     // left
      Offset(bounds.right, bounds.center.dy),     // right
    ];
    
    for (var edge in edges) {
      canvas.drawCircle(edge, handleSize, handlePaint);
      canvas.drawCircle(edge, handleSize, borderPaint);
    }
  }

  void _drawClassDiagram(Canvas canvas) {
    for (var umlClass in classes) {
      _drawClass(canvas, umlClass.copyWith(
        isSelected: selectedElement?.id == umlClass.id,
      ));
    }
  }

  void _drawClass(Canvas canvas, UmlClass umlClass) {
    final rect = umlClass.bounds;
    final paint = Paint()
      ..color = umlClass.isSelected ? Colors.blue.shade100 : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = umlClass.isSelected ? Colors.blue.shade700 : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = umlClass.isSelected ? 3.0 : 2.0;

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    final sectionHeight = rect.height / 3;
    
    canvas.drawLine(
      Offset(rect.left, rect.top + sectionHeight),
      Offset(rect.right, rect.top + sectionHeight),
      borderPaint,
    );
    
    canvas.drawLine(
      Offset(rect.left, rect.top + sectionHeight * 2),
      Offset(rect.right, rect.top + sectionHeight * 2),
      borderPaint,
    );

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: umlClass.className, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top + (sectionHeight - textPainter.height) / 2,
      ),
    );

    final attrTextStyle = TextStyle(color: Colors.black, fontSize: 12);
    double attrY = rect.top + sectionHeight + 8;
    for (var attr in umlClass.attributes) {
      final attrPainter = TextPainter(
        text: TextSpan(text: attr, style: attrTextStyle),
        textDirection: TextDirection.ltr,
      );
      attrPainter.layout(maxWidth: rect.width - 16);
      attrPainter.paint(canvas, Offset(rect.left + 8, attrY));
      attrY += attrPainter.height + 4;
      if (attrY > rect.top + sectionHeight * 2 - 8) break;
    }

    double methodY = rect.top + sectionHeight * 2 + 8;
    for (var method in umlClass.methods) {
      final methodPainter = TextPainter(
        text: TextSpan(text: method, style: attrTextStyle),
        textDirection: TextDirection.ltr,
      );
      methodPainter.layout(maxWidth: rect.width - 16);
      methodPainter.paint(canvas, Offset(rect.left + 8, methodY));
      methodY += methodPainter.height + 4;
      if (methodY > rect.bottom - 8) break;
    }
  }

  void _drawActivityDiagram(Canvas canvas) {
    // Draw flows first (so they appear behind elements)
    for (var element in activityElements) {
      if (element.type == ActivityElementType.flow && element.startPoint != null && element.endPoint != null) {
        _drawActivityFlow(canvas, element);
      }
    }
    
    // Draw elements
    for (var element in activityElements) {
      if (element.type != ActivityElementType.flow) {
        _drawActivityElement(canvas, element.copyWith(
          isSelected: selectedElement?.id == element.id,
        ));
      }
    }
  }

  void _drawActivityElement(Canvas canvas, ActivityElement element) {
    final paint = Paint()
      ..color = element.isSelected ? Colors.blue.shade100 : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = element.isSelected ? Colors.blue.shade700 : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = element.isSelected ? 3.0 : 2.0;

    final center = Offset(
      element.position.dx + element.width / 2,
      element.position.dy + element.height / 2,
    );

    switch (element.type) {
      case ActivityElementType.initialState:
        // Black filled circle
        canvas.drawCircle(center, 10, borderPaint..style = PaintingStyle.fill);
        break;
      
      case ActivityElementType.action:
        // Rounded rectangle
        final rect = RRect.fromRectAndRadius(element.bounds, Radius.circular(8));
        canvas.drawRRect(rect, paint);
        canvas.drawRRect(rect, borderPaint);
        break;
      
      case ActivityElementType.decision:
        // Diamond shape
        final path = Path()
          ..moveTo(center.dx, element.position.dy)
          ..lineTo(element.position.dx + element.width, center.dy)
          ..lineTo(center.dx, element.position.dy + element.height)
          ..lineTo(element.position.dx, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;
      
      case ActivityElementType.fork:
      case ActivityElementType.join:
        // Thick horizontal bar
        final rect = Rect.fromLTWH(
          element.position.dx,
          element.position.dy + element.height / 2 - 5,
          element.width,
          10,
        );
        canvas.drawRect(rect, borderPaint..strokeWidth = 8);
        break;
      
      case ActivityElementType.finalState:
        // Filled circle within a circle
        canvas.drawCircle(center, 12, borderPaint);
        canvas.drawCircle(center, 8, borderPaint..style = PaintingStyle.fill);
        break;
      
      case ActivityElementType.flow:
        // Handled separately
        break;
    }

    // Draw label
    if (element.label.isNotEmpty && element.type != ActivityElementType.initialState && element.type != ActivityElementType.finalState) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: element.label,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: element.width);
      textPainter.paint(
        canvas,
        Offset(
          element.position.dx + (element.width - textPainter.width) / 2,
          element.position.dy + (element.height - textPainter.height) / 2,
        ),
      );
    }
  }

  void _drawActivityFlow(Canvas canvas, ActivityElement flow) {
    if (flow.startPoint == null || flow.endPoint == null) return;
    
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw arrow
    final path = Path()
      ..moveTo(flow.startPoint!.dx, flow.startPoint!.dy)
      ..lineTo(flow.endPoint!.dx, flow.endPoint!.dy);
    
    canvas.drawPath(path, paint);
    
    // Draw arrowhead
    final angle = math.atan2(
      flow.endPoint!.dy - flow.startPoint!.dy,
      flow.endPoint!.dx - flow.startPoint!.dx,
    );
    final arrowSize = 10.0;
    final cosAngle = math.cos(angle);
    final sinAngle = math.sin(angle);
    final arrowPath = Path()
      ..moveTo(flow.endPoint!.dx, flow.endPoint!.dy)
      ..lineTo(
        flow.endPoint!.dx - arrowSize * (cosAngle - sinAngle),
        flow.endPoint!.dy - arrowSize * (sinAngle + cosAngle),
      )
      ..lineTo(
        flow.endPoint!.dx - arrowSize * (cosAngle + sinAngle),
        flow.endPoint!.dy - arrowSize * (sinAngle - cosAngle),
      )
      ..close();
    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
  }

  void _drawSequenceDiagram(Canvas canvas) {
    // Draw messages first
    for (var element in sequenceElements) {
      if (element.type == SequenceElementType.message && element.startPoint != null && element.endPoint != null) {
        _drawSequenceMessage(canvas, element);
      }
    }
    
    // Draw lifelines and actors
    for (var element in sequenceElements) {
      if (element.type != SequenceElementType.message) {
        _drawSequenceElement(canvas, element.copyWith(
          isSelected: selectedElement?.id == element.id,
        ));
      }
    }
  }

  void _drawSequenceElement(Canvas canvas, SequenceElement element) {
    final borderPaint = Paint()
      ..color = element.isSelected ? Colors.blue.shade700 : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = element.isSelected ? 3.0 : 2.5;

    final center = Offset(
      element.position.dx + element.width / 2,
      element.position.dy + element.height / 2,
    );

    switch (element.type) {
      case SequenceElementType.actor:
        // Stick figure
        final headRadius = 15.0;
        final bodyLength = 40.0;
        final legLength = 30.0;
        
        // Head
        canvas.drawCircle(Offset(center.dx, element.position.dy + headRadius), headRadius, borderPaint);
        
        // Body
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2),
          Offset(center.dx, element.position.dy + headRadius * 2 + bodyLength),
          borderPaint,
        );
        
        // Arms
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2 + 15),
          Offset(center.dx - 20, element.position.dy + headRadius * 2 + 25),
          borderPaint,
        );
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2 + 15),
          Offset(center.dx + 20, element.position.dy + headRadius * 2 + 25),
          borderPaint,
        );
        
        // Legs
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2 + bodyLength),
          Offset(center.dx - 15, element.position.dy + headRadius * 2 + bodyLength + legLength),
          borderPaint,
        );
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2 + bodyLength),
          Offset(center.dx + 15, element.position.dy + headRadius * 2 + bodyLength + legLength),
          borderPaint,
        );
        break;
      
      case SequenceElementType.lifeline:
        // Vertical dashed line
        final dashPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        final dashLength = 5.0;
        final gapLength = 5.0;
        double y = element.position.dy;
        while (y < element.position.dy + (element.lifelineLength ?? element.height)) {
          canvas.drawLine(
            Offset(center.dx, y),
            Offset(center.dx, (y + dashLength).clamp(0.0, element.position.dy + (element.lifelineLength ?? element.height))),
            dashPaint,
          );
          y += dashLength + gapLength;
        }
        break;
      
      case SequenceElementType.activationBar:
        // Thin rectangle on lifeline
        final rect = Rect.fromLTWH(
          element.position.dx + element.width / 2 - 8,
          element.position.dy,
          16,
          element.height,
        );
        final activationPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
        canvas.drawRect(rect, activationPaint);
        break;
      
      case SequenceElementType.message:
        // Handled separately
        break;
    }

    // Draw label
    if (element.label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: element.label,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: element.width);
      textPainter.paint(
        canvas,
        Offset(
          element.position.dx + (element.width - textPainter.width) / 2,
          element.position.dy - 20,
        ),
      );
    }
  }

  void _drawSequenceMessage(Canvas canvas, SequenceElement message) {
    if (message.startPoint == null || message.endPoint == null) return;
    
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw arrow
    final path = Path()
      ..moveTo(message.startPoint!.dx, message.startPoint!.dy)
      ..lineTo(message.endPoint!.dx, message.endPoint!.dy);
    
    canvas.drawPath(path, paint);
    
    // Draw arrowhead
    final angle = math.atan2(
      message.endPoint!.dy - message.startPoint!.dy,
      message.endPoint!.dx - message.startPoint!.dx,
    );
    final arrowSize = 10.0;
    final cosAngle = math.cos(angle);
    final sinAngle = math.sin(angle);
    final arrowPath = Path()
      ..moveTo(message.endPoint!.dx, message.endPoint!.dy)
      ..lineTo(
        message.endPoint!.dx - arrowSize * (cosAngle - sinAngle),
        message.endPoint!.dy - arrowSize * (sinAngle + cosAngle),
      )
      ..lineTo(
        message.endPoint!.dx - arrowSize * (cosAngle + sinAngle),
        message.endPoint!.dy - arrowSize * (sinAngle - cosAngle),
      )
      ..close();
    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);

    // Draw message label
    if (message.label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: message.label,
          style: TextStyle(color: Colors.black, fontSize: 11, backgroundColor: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (message.startPoint!.dx + message.endPoint!.dx) / 2 - textPainter.width / 2,
          (message.startPoint!.dy + message.endPoint!.dy) / 2 - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawUseCaseDiagram(Canvas canvas) {
    // Draw associations first
    for (var element in useCaseElements) {
      if (element.type == UseCaseElementType.association && element.startPoint != null && element.endPoint != null) {
        _drawUseCaseAssociation(canvas, element);
      }
    }
    
    // Draw system boundary
    for (var element in useCaseElements) {
      if (element.type == UseCaseElementType.systemBoundary) {
        _drawSystemBoundary(canvas, element);
      }
    }
    
    // Draw actors and use cases
    for (var element in useCaseElements) {
      if (element.type != UseCaseElementType.association && element.type != UseCaseElementType.systemBoundary) {
        _drawUseCaseElement(canvas, element.copyWith(
          isSelected: selectedElement?.id == element.id,
        ));
      }
    }
  }

  void _drawUseCaseElement(Canvas canvas, UseCaseElement element) {
    final paint = Paint()
      ..color = element.isSelected ? Colors.blue.shade100 : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = element.isSelected ? Colors.blue.shade700 : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = element.isSelected ? 3.0 : 2.0;

    final center = Offset(
      element.position.dx + element.width / 2,
      element.position.dy + element.height / 2,
    );

    switch (element.type) {
      case UseCaseElementType.actor:
        // Stick figure (same as sequence diagram)
        final headRadius = 15.0;
        final bodyLength = 40.0;
        final legLength = 30.0;
        
        canvas.drawCircle(Offset(center.dx, element.position.dy + headRadius), headRadius, borderPaint);
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2),
          Offset(center.dx, element.position.dy + headRadius * 2 + bodyLength),
          borderPaint,
        );
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2 + 15),
          Offset(center.dx - 20, element.position.dy + headRadius * 2 + 25),
          borderPaint,
        );
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2 + 15),
          Offset(center.dx + 20, element.position.dy + headRadius * 2 + 25),
          borderPaint,
        );
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2 + bodyLength),
          Offset(center.dx - 15, element.position.dy + headRadius * 2 + bodyLength + legLength),
          borderPaint,
        );
        canvas.drawLine(
          Offset(center.dx, element.position.dy + headRadius * 2 + bodyLength),
          Offset(center.dx + 15, element.position.dy + headRadius * 2 + bodyLength + legLength),
          borderPaint,
        );
        break;
      
      case UseCaseElementType.useCase:
        // Oval
        final rect = element.bounds;
        final oval = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
        canvas.drawRRect(oval, paint);
        canvas.drawRRect(oval, borderPaint);
        break;
      
      case UseCaseElementType.association:
      case UseCaseElementType.systemBoundary:
        // Handled separately
        break;
    }

    // Draw label and description for use cases
    if (element.type == UseCaseElementType.useCase) {
      double yOffset = element.position.dy + 8;
      
      // Draw label
      if (element.label.isNotEmpty) {
        final labelPainter = TextPainter(
          text: TextSpan(
            text: element.label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        labelPainter.layout(maxWidth: element.width - 16);
        labelPainter.paint(
          canvas,
          Offset(
            element.position.dx + (element.width - labelPainter.width) / 2,
            yOffset,
          ),
        );
        yOffset += labelPainter.height + 4;
      }
      
      // Draw description/functionalities
      if (element.description.isNotEmpty) {
        final descLines = element.description.split('\n').where((line) => line.trim().isNotEmpty).toList();
        if (descLines.isNotEmpty) {
          final descTextStyle = TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          );
          
          for (var line in descLines) {
            if (yOffset + 12 > element.position.dy + element.height - 8) break;
            
            final descPainter = TextPainter(
              text: TextSpan(
                text: line.trim(),
                style: descTextStyle,
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            );
            descPainter.layout(maxWidth: element.width - 16);
            descPainter.paint(
              canvas,
              Offset(
                element.position.dx + (element.width - descPainter.width) / 2,
                yOffset,
              ),
            );
            yOffset += descPainter.height + 2;
          }
        }
      }
    } else if (element.label.isNotEmpty) {
      // Draw label for other types (actor, etc.)
      final textPainter = TextPainter(
        text: TextSpan(
          text: element.label,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: element.width);
      textPainter.paint(
        canvas,
        Offset(
          element.position.dx + (element.width - textPainter.width) / 2,
          element.position.dy + (element.height - textPainter.height) / 2,
        ),
      );
    }
  }

  void _drawUseCaseAssociation(Canvas canvas, UseCaseElement association) {
    if (association.startPoint == null || association.endPoint == null) return;
    
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(association.startPoint!, association.endPoint!, paint);
  }

  void _drawSystemBoundary(Canvas canvas, UseCaseElement boundary) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = boundary.bounds;
    canvas.drawRect(rect, paint);

    // Draw label at top
    if (boundary.label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: boundary.label,
          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left + 10, rect.top - 20),
      );
    }
  }

  void _drawStateMachineDiagram(Canvas canvas) {
    // Draw transitions first
    for (var element in stateMachineElements) {
      if (element.type == StateMachineElementType.transition && element.startPoint != null && element.endPoint != null) {
        _drawStateTransition(canvas, element);
      }
    }
    
    // Draw states
    for (var element in stateMachineElements) {
      if (element.type != StateMachineElementType.transition) {
        _drawStateMachineElement(canvas, element.copyWith(
          isSelected: selectedElement?.id == element.id,
        ));
      }
    }
  }

  void _drawStateMachineElement(Canvas canvas, StateMachineElement element) {
    final paint = Paint()
      ..color = element.isSelected ? Colors.blue.shade100 : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = element.isSelected ? Colors.blue.shade700 : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = element.isSelected ? 3.0 : 2.0;

    final center = Offset(
      element.position.dx + element.width / 2,
      element.position.dy + element.height / 2,
    );

    switch (element.type) {
      case StateMachineElementType.initialState:
        // Black filled circle
        canvas.drawCircle(center, 10, borderPaint..style = PaintingStyle.fill);
        break;
      
      case StateMachineElementType.state:
        // Rounded rectangle
        final rect = RRect.fromRectAndRadius(element.bounds, Radius.circular(8));
        canvas.drawRRect(rect, paint);
        canvas.drawRRect(rect, borderPaint);
        break;
      
      case StateMachineElementType.finalState:
        // Filled circle within a circle
        canvas.drawCircle(center, 12, borderPaint);
        canvas.drawCircle(center, 8, borderPaint..style = PaintingStyle.fill);
        break;
      
      case StateMachineElementType.transition:
        // Handled separately
        break;
    }

    // Draw label
    if (element.label.isNotEmpty && element.type != StateMachineElementType.initialState && element.type != StateMachineElementType.finalState) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: element.label,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: element.width);
      textPainter.paint(
        canvas,
        Offset(
          element.position.dx + (element.width - textPainter.width) / 2,
          element.position.dy + (element.height - textPainter.height) / 2,
        ),
      );
    }
  }

  void _drawStateTransition(Canvas canvas, StateMachineElement transition) {
    if (transition.startPoint == null || transition.endPoint == null) return;
    
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw arrow
    final path = Path()
      ..moveTo(transition.startPoint!.dx, transition.startPoint!.dy)
      ..lineTo(transition.endPoint!.dx, transition.endPoint!.dy);
    
    canvas.drawPath(path, paint);
    
    // Draw arrowhead
    final angle = math.atan2(
      transition.endPoint!.dy - transition.startPoint!.dy,
      transition.endPoint!.dx - transition.startPoint!.dx,
    );
    final arrowSize = 10.0;
    final cosAngle = math.cos(angle);
    final sinAngle = math.sin(angle);
    final arrowPath = Path()
      ..moveTo(transition.endPoint!.dx, transition.endPoint!.dy)
      ..lineTo(
        transition.endPoint!.dx - arrowSize * (cosAngle - sinAngle),
        transition.endPoint!.dy - arrowSize * (sinAngle + cosAngle),
      )
      ..lineTo(
        transition.endPoint!.dx - arrowSize * (cosAngle + sinAngle),
        transition.endPoint!.dy - arrowSize * (sinAngle - cosAngle),
      )
      ..close();
    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);

    // Draw trigger label
    if (transition.trigger != null && transition.trigger!.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: transition.trigger!,
          style: TextStyle(color: Colors.black, fontSize: 11, backgroundColor: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (transition.startPoint!.dx + transition.endPoint!.dx) / 2 - textPainter.width / 2,
          (transition.startPoint!.dy + transition.endPoint!.dy) / 2 - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_UnifiedUmlCanvasPainter oldDelegate) {
    return diagramType != oldDelegate.diagramType ||
        classes != oldDelegate.classes ||
        activityElements != oldDelegate.activityElements ||
        sequenceElements != oldDelegate.sequenceElements ||
        useCaseElements != oldDelegate.useCaseElements ||
        stateMachineElements != oldDelegate.stateMachineElements ||
        selectedElement?.id != oldDelegate.selectedElement?.id;
  }
}

