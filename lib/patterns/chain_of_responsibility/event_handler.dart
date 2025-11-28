// DESIGN PATTERN: Chain of Responsibility Pattern
// Passes requests along a chain of handlers until one handles it
// Used in: Event handling, gesture processing, command routing

import 'package:flutter/material.dart';
import 'dart:ui';

abstract class EventHandler {
  EventHandler? _nextHandler;
  
  void setNext(EventHandler handler) {
    _nextHandler = handler;
  }
  
  bool handle(EventContext context) {
    if (canHandle(context)) {
      return process(context);
    } else if (_nextHandler != null) {
      return _nextHandler!.handle(context);
    }
    return false;
  }
  
  bool canHandle(EventContext context);
  bool process(EventContext context);
}

class EventContext {
  final Offset position;
  final dynamic element;
  final String eventType;
  final Map<String, dynamic> data;
  
  EventContext({
    required this.position,
    this.element,
    required this.eventType,
    this.data = const {},
  });
}

// Concrete handlers
class SelectionHandler extends EventHandler {
  @override
  bool canHandle(EventContext context) {
    return context.eventType == 'select' && context.element != null;
  }
  
  @override
  bool process(EventContext context) {
    // Selection logic handled by parent widget
    return true;
  }
}

class DragHandler extends EventHandler {
  @override
  bool canHandle(EventContext context) {
    return context.eventType == 'drag' && context.element != null;
  }
  
  @override
  bool process(EventContext context) {
    // Drag logic handled by parent widget
    return true;
  }
}

class ResizeHandler extends EventHandler {
  @override
  bool canHandle(EventContext context) {
    return context.eventType == 'resize' && context.element != null;
  }
  
  @override
  bool process(EventContext context) {
    // Resize logic handled by parent widget
    return true;
  }
}

class DeleteHandler extends EventHandler {
  @override
  bool canHandle(EventContext context) {
    return context.eventType == 'delete' && context.element != null;
  }
  
  @override
  bool process(EventContext context) {
    // Delete logic handled by parent widget
    return true;
  }
}

// Chain builder
class EventHandlerChain {
  static EventHandler buildChain() {
    final selection = SelectionHandler();
    final drag = DragHandler();
    final resize = ResizeHandler();
    final delete = DeleteHandler();
    
    selection.setNext(drag);
    drag.setNext(resize);
    resize.setNext(delete);
    
    return selection;
  }
}

