import 'package:flutter/material.dart';
import '../models/uml_class.dart';

class UmlCanvas extends StatefulWidget {
  final List<UmlClass> classes;
  final Function(UmlClass) onClassUpdate;
  final Function(UmlClass) onClassSelect;
  final GlobalKey repaintBoundaryKey;

  const UmlCanvas({
    super.key,
    required this.classes,
    required this.onClassUpdate,
    required this.onClassSelect,
    required this.repaintBoundaryKey,
  });

  @override
  State<UmlCanvas> createState() => _UmlCanvasState();
}

class _UmlCanvasState extends State<UmlCanvas> {
  UmlClass? _selectedClass;
  UmlClass? _draggingClass;
  Offset? _dragOffset;

  void _handlePanStart(DragStartDetails details) {
    final point = details.localPosition;
    
    // Check if clicking on an existing class
    for (var umlClass in widget.classes.reversed) {
      if (umlClass.containsPoint(point)) {
        _selectedClass = umlClass;
        _draggingClass = umlClass;
        _dragOffset = Offset(
          point.dx - umlClass.position.dx,
          point.dy - umlClass.position.dy,
        );
        widget.onClassSelect(umlClass);
        setState(() {});
        return;
      }
    }
    
    // No class selected
    _selectedClass = null;
    _draggingClass = null;
    widget.onClassSelect(UmlClass(id: '', position: Offset.zero));
    setState(() {});
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_draggingClass != null && _dragOffset != null) {
      final newPosition = Offset(
        details.localPosition.dx - _dragOffset!.dx,
        details.localPosition.dy - _dragOffset!.dy,
      );
      
      widget.onClassUpdate(
        _draggingClass!.copyWith(position: newPosition),
      );
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _draggingClass = null;
    _dragOffset = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: CustomPaint(
        painter: _UmlCanvasPainter(
          classes: widget.classes,
          selectedClass: _selectedClass,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _UmlCanvasPainter extends CustomPainter {
  final List<UmlClass> classes;
  final UmlClass? selectedClass;

  _UmlCanvasPainter({
    required this.classes,
    this.selectedClass,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid background
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    const gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw all classes
    for (var umlClass in classes) {
      _drawClass(canvas, umlClass.copyWith(
        isSelected: selectedClass?.id == umlClass.id,
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

    // Draw main rectangle
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Draw three sections with dividers
    final sectionHeight = rect.height / 3;
    
    // First divider (between class name and attributes)
    canvas.drawLine(
      Offset(rect.left, rect.top + sectionHeight),
      Offset(rect.right, rect.top + sectionHeight),
      borderPaint,
    );
    
    // Second divider (between attributes and methods)
    canvas.drawLine(
      Offset(rect.left, rect.top + sectionHeight * 2),
      Offset(rect.right, rect.top + sectionHeight * 2),
      borderPaint,
    );

    // Draw text
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

    // Draw attributes
    final attrTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );
    double attrY = rect.top + sectionHeight + 8;
    for (var attr in umlClass.attributes) {
      final attrPainter = TextPainter(
        text: TextSpan(text: attr, style: attrTextStyle),
        textDirection: TextDirection.ltr,
      );
      attrPainter.layout(maxWidth: rect.width - 16);
      attrPainter.paint(
        canvas,
        Offset(rect.left + 8, attrY),
      );
      attrY += attrPainter.height + 4;
      if (attrY > rect.top + sectionHeight * 2 - 8) break;
    }

    // Draw methods
    double methodY = rect.top + sectionHeight * 2 + 8;
    for (var method in umlClass.methods) {
      final methodPainter = TextPainter(
        text: TextSpan(text: method, style: attrTextStyle),
        textDirection: TextDirection.ltr,
      );
      methodPainter.layout(maxWidth: rect.width - 16);
      methodPainter.paint(
        canvas,
        Offset(rect.left + 8, methodY),
      );
      methodY += methodPainter.height + 4;
      if (methodY > rect.bottom - 8) break;
    }
  }

  @override
  bool shouldRepaint(_UmlCanvasPainter oldDelegate) {
    return classes != oldDelegate.classes ||
        selectedClass?.id != oldDelegate.selectedClass?.id;
  }
}

