// DESIGN PATTERN: Decorator Pattern
// Adds visual decorations (selection, highlighting, borders) to elements dynamically
// Used in: Visual enhancements for selected/hovered elements

import 'package:flutter/material.dart';
import 'dart:ui';

abstract class ElementDecorator {
  void decorate(Canvas canvas, Rect bounds, Paint paint);
}

class SelectionDecorator implements ElementDecorator {
  @override
  void decorate(Canvas canvas, Rect bounds, Paint paint) {
    final selectionPaint = Paint()
      ..color = Colors.blue.shade100
      ..style = PaintingStyle.fill;
    canvas.drawRect(bounds, selectionPaint);
  }
}

class BorderDecorator implements ElementDecorator {
  final Color borderColor;
  final double borderWidth;
  
  BorderDecorator({this.borderColor = Colors.blue, this.borderWidth = 3.0});
  
  @override
  void decorate(Canvas canvas, Rect bounds, Paint paint) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRect(bounds, borderPaint);
  }
}

class ShadowDecorator implements ElementDecorator {
  @override
  void decorate(Canvas canvas, Rect bounds, Paint paint) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRect(
      bounds.translate(2, 2),
      shadowPaint,
    );
  }
}

// Composite decorator - combines multiple decorators
class CompositeDecorator implements ElementDecorator {
  final List<ElementDecorator> decorators;
  
  CompositeDecorator(this.decorators);
  
  @override
  void decorate(Canvas canvas, Rect bounds, Paint paint) {
    for (var decorator in decorators) {
      decorator.decorate(canvas, bounds, paint);
    }
  }
}

