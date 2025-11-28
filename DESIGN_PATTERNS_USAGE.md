# Design Patterns Usage and Functionality

This document explains where each design pattern is used in the UMLify application and what functionality they add.

## 1. Factory Pattern
**Location:** `lib/patterns/factory/element_factory.dart`
**Usage in:** `lib/main.dart` (all `_add*` methods)

### Functionality Added:
- **Centralized Element Creation**: Instead of manually creating elements with `new UmlClass(...)`, we use factories
- **Consistent Default Values**: All elements are created with consistent default sizes from `AppConfig`
- **Easy Extension**: Adding new element types only requires creating a new factory class
- **Type Safety**: Factory ensures correct element types are created for each diagram type

### Example Usage:
```dart
// Before: Manual creation
_classes.add(UmlClass(id: 'class_1', position: Offset(100, 100), ...));

// After: Factory pattern
final factory = ElementFactoryManager.getFactory(DiagramType.classDiagram);
final newClass = factory.createElement('class_1', Offset(100, 100), params: {...});
```

### Benefits:
- ✅ Reduces code duplication
- ✅ Makes element creation consistent
- ✅ Easier to maintain and extend

---

## 2. Singleton Pattern
**Location:** `lib/patterns/singleton/app_config.dart`
**Usage in:** `lib/main.dart`, `lib/widgets/unified_uml_canvas.dart`

### Functionality Added:
- **Global Configuration Management**: Single source of truth for app-wide settings
- **Consistent Default Values**: Canvas size, grid size, element dimensions all in one place
- **Easy Configuration Changes**: Change defaults in one place, affects entire app
- **Memory Efficiency**: Only one instance exists in memory

### Example Usage:
```dart
// Before: Hard-coded values scattered everywhere
minScale: 0.1,
maxScale: 4.0,
width: 2000,
height: 2000,

// After: Singleton config
final config = AppConfig();
minScale: config.minScale,
maxScale: config.maxScale,
width: config.canvasWidth,
height: config.canvasHeight,
```

### Benefits:
- ✅ Centralized configuration
- ✅ Easy to modify app-wide settings
- ✅ Prevents configuration inconsistencies

---

## 3. Template Method Pattern
**Location:** `lib/patterns/template/renderer_template.dart`
**Usage in:** Canvas rendering (structure defined, can be extended)

### Functionality Added:
- **Standardized Rendering Process**: Defines the algorithm structure for rendering
- **Consistent Rendering Steps**: All renderers follow: prepare → draw shape → draw label → draw decorations
- **Extensibility**: Easy to add new renderer types by extending the template
- **Code Reusability**: Common rendering logic is shared

### Example Usage:
```dart
// Template defines the rendering algorithm
abstract class ElementRenderer {
  void render(Canvas canvas, dynamic element) {
    _preparePaint(element);
    _drawShape(canvas, element);
    _drawLabel(canvas, element);
    _drawDecorations(canvas, element);
  }
}
```

### Benefits:
- ✅ Consistent rendering across all element types
- ✅ Easy to add new renderers
- ✅ Reduces code duplication in rendering logic

---

## 4. Decorator Pattern
**Location:** `lib/patterns/decorator/element_decorator.dart`
**Usage in:** Visual enhancements for selected elements

### Functionality Added:
- **Dynamic Visual Enhancements**: Add selection borders, shadows, highlights without modifying element classes
- **Composable Decorations**: Combine multiple decorations (selection + border + shadow)
- **Flexible Styling**: Change visual appearance without changing element code
- **Separation of Concerns**: Visual decorations separate from element logic

### Example Usage:
```dart
// Can add decorations dynamically
final decorator = CompositeDecorator([
  SelectionDecorator(),
  BorderDecorator(borderColor: Colors.blue, borderWidth: 3.0),
  ShadowDecorator(),
]);
decorator.decorate(canvas, element.bounds, paint);
```

### Benefits:
- ✅ Flexible visual customization
- ✅ Can add/remove decorations at runtime
- ✅ Keeps element classes clean

---

## 5. Adapter Pattern
**Location:** `lib/patterns/adapter/element_adapter.dart`
**Usage in:** Unified element handling across different types

### Functionality Added:
- **Unified Interface**: Treat all element types (UmlClass, ActivityElement, etc.) the same way
- **Type-Independent Operations**: Perform operations (select, move, delete) without knowing specific type
- **Code Simplification**: Reduces need for type checking and casting
- **Easy Element Management**: Single interface for all element operations

### Example Usage:
```dart
// Before: Type-specific handling
if (element is UmlClass) {
  // handle class
} else if (element is ActivityElement) {
  // handle activity
} // ... many more if-else

// After: Unified adapter interface
final adapter = ElementAdapterFactory.createAdapter(element);
adapter.id; // Works for all types
adapter.bounds; // Works for all types
adapter.containsPoint(point); // Works for all types
```

### Benefits:
- ✅ Reduces code complexity
- ✅ Makes element operations type-agnostic
- ✅ Easier to add new element types

---

## 6. Composite Pattern
**Location:** `lib/patterns/composite/element_composite.dart`
**Usage in:** Grouping elements together

### Functionality Added:
- **Element Grouping**: Group multiple elements together and treat as single unit
- **Hierarchical Structure**: Elements can be grouped into groups of groups
- **Bulk Operations**: Move, delete, or transform entire groups at once
- **Part-Whole Relationships**: Treat individual elements and groups uniformly

### Example Usage:
```dart
// Create a group
final group = ElementGroup('group1');
group.add(ElementLeaf(adapter1));
group.add(ElementLeaf(adapter2));

// Operate on group as single unit
group.move(Offset(10, 10)); // Moves all elements
group.bounds; // Returns bounding box of all elements
```

### Benefits:
- ✅ Enables element grouping functionality
- ✅ Simplifies bulk operations
- ✅ Maintains tree structure of elements

---

## 7. Facade Pattern
**Location:** `lib/patterns/facade/diagram_facade.dart`
**Usage in:** `lib/main.dart` (`_saveAsPng` method)

### Functionality Added:
- **Simplified Save Operations**: Single method to save diagrams instead of complex logic
- **Export Functionality**: Export diagram state to JSON/dictionary format
- **Hides Complexity**: Complex save/load logic hidden behind simple interface
- **Future Extensibility**: Easy to add new export formats (PDF, SVG, etc.)

### Example Usage:
```dart
// Before: Complex save logic with multiple checks
final path = await ImageSaver.saveAsPng(_repaintBoundaryKey);
if (path != null) { ... } else {
  final filePath = await ImageSaver.saveToFile(_repaintBoundaryKey);
  // ... more complex logic
}

// After: Simple facade
final path = await DiagramFacade.saveDiagram(_repaintBoundaryKey, toGallery: true);

// Export diagram state
final state = DiagramFacade.exportDiagramState(
  diagramType: _selectedDiagramType,
  classes: _classes,
  // ...
);
```

### Benefits:
- ✅ Simplifies complex operations
- ✅ Single entry point for save/export
- ✅ Easy to extend with new formats

---

## 8. Chain of Responsibility Pattern
**Location:** `lib/patterns/chain_of_responsibility/event_handler.dart`
**Usage in:** Event handling and gesture processing

### Functionality Added:
- **Flexible Event Handling**: Events are passed through chain until handled
- **Extensible Event System**: Easy to add new event handlers
- **Separation of Concerns**: Each handler handles specific event type
- **Dynamic Handler Chain**: Can modify handler chain at runtime

### Example Usage:
```dart
// Build handler chain
final chain = EventHandlerChain.buildChain();

// Handle events
final context = EventContext(
  position: point,
  element: selectedElement,
  eventType: 'select',
);
chain.handle(context); // Automatically routes to correct handler
```

### Benefits:
- ✅ Flexible event routing
- ✅ Easy to add new event types
- ✅ Decouples event source from handlers

---

## 9. Observer Pattern
**Location:** `lib/patterns/observer/element_observer.dart`
**Usage in:** `lib/main.dart` (state notifications)

### Functionality Added:
- **State Change Notifications**: Automatically notify observers when elements change
- **Loose Coupling**: Elements don't need to know about UI components
- **Multiple Observers**: Multiple components can listen to same events
- **Reactive Updates**: UI automatically updates when elements change

### Example Usage:
```dart
// Subscribe to element changes
_elementSubject.attach(this);

// Notify when element added
_elementSubject.notifyElementAdded(newElement);
// All observers automatically notified

// UI automatically updates via observer callbacks
@override
void onElementAdded(dynamic element) {
  setState(() {}); // UI updates
}
```

### Benefits:
- ✅ Automatic UI updates
- ✅ Decouples data from UI
- ✅ Multiple components can react to changes
- ✅ Makes app more reactive

---

## 10. State Pattern
**Location:** `lib/patterns/state/diagram_state.dart`
**Usage in:** Managing interaction modes (select, drag, resize)

### Functionality Added:
- **Mode Management**: Different behaviors for different interaction modes
- **State Transitions**: Clean transitions between select, drag, resize modes
- **Behavior Encapsulation**: Each state encapsulates its own behavior
- **Easy Mode Addition**: Add new interaction modes easily

### Example Usage:
```dart
// Different behaviors based on state
class DragState implements DiagramState {
  @override
  void handlePanUpdate(DragUpdateDetails details, DiagramContext context) {
    // Drag-specific logic
  }
}

class ResizeState implements DiagramState {
  @override
  void handlePanUpdate(DragUpdateDetails details, DiagramContext context) {
    // Resize-specific logic
  }
}
```

### Benefits:
- ✅ Clean state management
- ✅ Easy to add new interaction modes
- ✅ Encapsulates state-specific behavior

---

## 11. Command Pattern
**Location:** `lib/patterns/command/command.dart`
**Usage in:** `lib/main.dart` (all add/update/delete operations)

### Functionality Added:
- **UNDO/REDO FUNCTIONALITY**: This is the BIGGEST functional addition!
- **Action History**: All actions are recorded and can be undone
- **Macro Recording**: Can record sequences of commands
- **Transactional Operations**: Commands can be grouped and executed together

### Example Usage:
```dart
// Execute command (automatically added to history)
_commandInvoker.executeCommand(
  AddElementCommand(element: newClass, ...)
);

// Undo last action
_commandInvoker.undo(); // Removes the element

// Redo undone action
_commandInvoker.redo(); // Adds it back
```

### Benefits:
- ✅ **UNDO/REDO - Major new functionality!**
- ✅ Action history tracking
- ✅ Can replay commands
- ✅ Enables future macro functionality

---

## Performance Optimizations

### Lazy Loading
**Location:** `lib/services/performance_cache.dart`
**Functionality Added:**
- **Faster Initial Load**: Resources loaded only when needed
- **Reduced Memory Usage**: Only load what's visible
- **Improved Startup Time**: App starts faster

### Caching
**Location:** `lib/services/performance_cache.dart`
**Functionality Added:**
- **Faster Rendering**: Cached paint operations don't need to be redrawn
- **Reduced CPU Usage**: Expensive operations cached
- **Smoother UI**: Less work during repaints

---

## Summary: What Functionality Do These Patterns Add?

### Direct User-Facing Features:
1. ✅ **UNDO/REDO** (Command Pattern) - Users can undo/redo actions
2. ✅ **Faster Loading** (Performance optimizations) - App loads much faster
3. ✅ **Consistent Element Creation** (Factory) - All elements have consistent defaults
4. ✅ **Global Settings** (Singleton) - Easy to configure app-wide settings

### Developer Benefits (Indirect User Benefits):
1. ✅ **Easier Maintenance** - Code is more organized and maintainable
2. ✅ **Easier Extension** - Adding new features is easier
3. ✅ **Better Performance** - Optimized rendering and caching
4. ✅ **More Reliable** - Patterns enforce good practices

### Future Extensibility:
- Easy to add new element types (Factory)
- Easy to add new export formats (Facade)
- Easy to add new event types (Chain of Responsibility)
- Easy to add new interaction modes (State)
- Easy to add grouping features (Composite)
- Easy to add visual themes (Decorator)

---

## Real-World Impact

**Before Patterns:**
- No undo/redo
- Slow loading
- Inconsistent element creation
- Hard to add new features
- Scattered configuration

**After Patterns:**
- ✅ Undo/redo functionality
- ✅ Faster loading with caching
- ✅ Consistent element creation
- ✅ Easy to extend
- ✅ Centralized configuration
- ✅ Better code organization
- ✅ More maintainable codebase

