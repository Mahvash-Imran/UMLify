// DESIGN PATTERN: Template Method Pattern
// Defines the skeleton of the rendering algorithm, letting subclasses override specific steps
// Used in: Canvas rendering for different diagram types

import 'package:flutter/material.dart';
import 'dart:ui';

abstract class ElementRenderer {
  // Template method - defines the algorithm structure
  void render(Canvas canvas, dynamic element) {
    _preparePaint(element);
    _drawShape(canvas, element);
    _drawLabel(canvas, element);
    _drawDecorations(canvas, element);
  }
  
  // Steps that subclasses must implement
  void _preparePaint(dynamic element);
  void _drawShape(Canvas canvas, dynamic element);
  void _drawLabel(Canvas canvas, dynamic element);
  void _drawDecorations(Canvas canvas, dynamic element);
  
  // Helper methods
  Paint _getSelectionPaint(bool isSelected) {
    return Paint()
      ..color = isSelected ? Colors.blue.shade100 : Colors.white
      ..style = PaintingStyle.fill;
  }
  
  Paint _getBorderPaint(bool isSelected) {
    return Paint()
      ..color = isSelected ? Colors.blue.shade700 : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 2.0;
  }
}

class ClassRenderer extends ElementRenderer {
  @override
  void _preparePaint(dynamic element) {
    // Preparation logic for class rendering
  }
  
  @override
  void _drawShape(Canvas canvas, dynamic element) {
    final rect = (element as dynamic).bounds;
    final paint = _getSelectionPaint(element.isSelected);
    final borderPaint = _getBorderPaint(element.isSelected);
    
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
  }
  
  @override
  void _drawLabel(Canvas canvas, dynamic element) {
    // Label drawing is handled in the main painter
  }
  
  @override
  void _drawDecorations(Canvas canvas, dynamic element) {
    // Additional decorations if needed
  }
}

