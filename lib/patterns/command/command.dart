// DESIGN PATTERN: Command Pattern
// Encapsulates a request as an object, allowing parameterization and undo/redo
// Used in: Undo/redo functionality, action history, macro recording

abstract class Command {
  void execute();
  void undo();
  String get description;
}

// Concrete commands
class AddElementCommand implements Command {
  final dynamic element;
  final List<dynamic> elementList;
  final Function(dynamic) onAdd;
  final Function(dynamic) onRemove;
  
  AddElementCommand({
    required this.element,
    required this.elementList,
    required this.onAdd,
    required this.onRemove,
  });
  
  @override
  void execute() {
    elementList.add(element);
    onAdd(element);
  }
  
  @override
  void undo() {
    elementList.remove(element);
    onRemove(element);
  }
  
  @override
  String get description => 'Add ${element.runtimeType}';
}

class DeleteElementCommand implements Command {
  final dynamic element;
  final List<dynamic> elementList;
  final Function(dynamic) onAdd;
  final Function(dynamic) onRemove;
  final int originalIndex;
  
  DeleteElementCommand({
    required this.element,
    required this.elementList,
    required this.onAdd,
    required this.onRemove,
  }) : originalIndex = elementList.indexOf(element);
  
  @override
  void execute() {
    elementList.remove(element);
    onRemove(element);
  }
  
  @override
  void undo() {
    if (originalIndex >= 0 && originalIndex <= elementList.length) {
      elementList.insert(originalIndex, element);
    } else {
      elementList.add(element);
    }
    onAdd(element);
  }
  
  @override
  String get description => 'Delete ${element.runtimeType}';
}

class UpdateElementCommand implements Command {
  final dynamic oldElement;
  final dynamic newElement;
  final List<dynamic> elementList;
  final Function(dynamic) onUpdate;
  final int elementIndex;
  
  UpdateElementCommand({
    required this.oldElement,
    required this.newElement,
    required this.elementList,
    required this.onUpdate,
  }) : elementIndex = elementList.indexOf(oldElement);
  
  @override
  void execute() {
    if (elementIndex >= 0 && elementIndex < elementList.length) {
      elementList[elementIndex] = newElement;
      onUpdate(newElement);
    }
  }
  
  @override
  void undo() {
    if (elementIndex >= 0 && elementIndex < elementList.length) {
      elementList[elementIndex] = oldElement;
      onUpdate(oldElement);
    }
  }
  
  @override
  String get description => 'Update ${oldElement.runtimeType}';
}

// Invoker - manages command history
class CommandInvoker {
  final List<Command> _history = [];
  int _currentIndex = -1;
  final int maxHistorySize = 50;
  
  void executeCommand(Command command) {
    // Remove any commands after current index (when undoing and then doing new action)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
    
    command.execute();
    _history.add(command);
    _currentIndex = _history.length - 1;
    
    // Limit history size
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _currentIndex--;
    }
  }
  
  void undo() {
    if (canUndo()) {
      _history[_currentIndex].undo();
      _currentIndex--;
    }
  }
  
  void redo() {
    if (canRedo()) {
      _currentIndex++;
      _history[_currentIndex].execute();
    }
  }
  
  bool canUndo() => _currentIndex >= 0;
  bool canRedo() => _currentIndex < _history.length - 1;
  
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
}

