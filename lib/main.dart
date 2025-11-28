// DESIGN PATTERNS USED IN THIS FILE:
// - Factory Pattern: ElementFactoryManager for creating elements
// - Singleton Pattern: AppConfig for global configuration
// - Observer Pattern: ElementSubject for state notifications
// - Command Pattern: CommandInvoker for undo/redo
// - Facade Pattern: DiagramFacade for save operations
// - Adapter Pattern: ElementAdapterFactory for unified element handling
// - Performance: Lazy loading and caching for faster rendering

import 'package:flutter/material.dart';
import 'dart:ui';
import 'models/diagram_type.dart';
import 'models/uml_class.dart';
import 'models/activity_element.dart';
import 'models/sequence_element.dart';
import 'models/use_case_element.dart';
import 'models/state_machine_element.dart';
import 'widgets/unified_uml_canvas.dart';
import 'widgets/diagram_component_panel.dart';
import 'widgets/text_editor_dialog.dart';
import 'widgets/element_editor_dialog.dart';
import 'services/image_saver.dart';
import 'patterns/factory/element_factory.dart';
import 'patterns/singleton/app_config.dart';
import 'patterns/observer/element_observer.dart';
import 'patterns/command/command.dart';
import 'patterns/facade/diagram_facade.dart';
import 'patterns/adapter/element_adapter.dart';
import 'services/performance_cache.dart';

void main() {
  // Initialize singleton configuration
  final config = AppConfig();
  
  // Preload resources asynchronously to improve initial load time
  PerformanceCache().preloadResources();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMLify - UML Diagram Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UmlEditorPage(),
    );
  }
}

class UmlEditorPage extends StatefulWidget {
  const UmlEditorPage({super.key});

  @override
  State<UmlEditorPage> createState() => _UmlEditorPageState();
}

class _UmlEditorPageState extends State<UmlEditorPage> implements ElementObserver {
  // DESIGN PATTERN: Singleton - Using AppConfig for global settings
  final AppConfig _config = AppConfig();
  
  DiagramType _selectedDiagramType = DiagramType.classDiagram;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  
  // DESIGN PATTERN: Observer - ElementSubject for state notifications
  final ElementSubject _elementSubject = ElementSubject();
  
  // DESIGN PATTERN: Command - CommandInvoker for undo/redo functionality
  final CommandInvoker _commandInvoker = CommandInvoker();
  
  // Class Diagram
  final List<UmlClass> _classes = [];
  UmlClass? _selectedClass;
  
  // Activity Diagram
  final List<ActivityElement> _activityElements = [];
  ActivityElement? _selectedActivityElement;
  
  // Sequence Diagram
  final List<SequenceElement> _sequenceElements = [];
  SequenceElement? _selectedSequenceElement;
  
  // Use Case Diagram
  final List<UseCaseElement> _useCaseElements = [];
  UseCaseElement? _selectedUseCaseElement;
  
  // State Machine Diagram
  final List<StateMachineElement> _stateMachineElements = [];
  StateMachineElement? _selectedStateMachineElement;
  
  int _nextId = 1;
  
  @override
  void initState() {
    super.initState();
    // DESIGN PATTERN: Observer - Attach this widget as observer
    _elementSubject.attach(this);
  }
  
  @override
  void dispose() {
    _elementSubject.detach(this);
    super.dispose();
  }
  
  // DESIGN PATTERN: Observer - Implement observer methods
  @override
  void onElementSelected(dynamic element) {
    // UI updates handled by setState in selection methods
  }
  
  @override
  void onElementUpdated(dynamic element) {
    setState(() {});
  }
  
  @override
  void onElementDeleted(String elementId) {
    setState(() {});
  }
  
  @override
  void onElementAdded(dynamic element) {
    setState(() {});
  }

  void _switchDiagramType(DiagramType type) {
    setState(() {
      _selectedDiagramType = type;
      // Clear selections when switching
      _selectedClass = null;
      _selectedActivityElement = null;
      _selectedSequenceElement = null;
      _selectedUseCaseElement = null;
      _selectedStateMachineElement = null;
    });
  }

  // DESIGN PATTERN: Factory - Using ElementFactoryManager to create elements
  // Class Diagram Methods
  void _addClass() {
    final factory = ElementFactoryManager.getFactory(DiagramType.classDiagram);
    final config = AppConfig();
    final newClass = factory.createElement(
      'class_$_nextId',
      Offset(100 + (_classes.length * 50), 100 + (_classes.length * 50)),
      params: {
        'className': 'Class$_nextId',
        'attributes': ['+ attribute1: String'],
        'methods': ['+ method1()'],
        'width': config.defaultClassWidth,
        'height': config.defaultClassHeight,
      },
    ) as UmlClass;
    
    // DESIGN PATTERN: Command - Execute add command for undo/redo
    final command = AddElementCommand(
      element: newClass,
      elementList: _classes,
      onAdd: (element) {
        _elementSubject.notifyElementAdded(element);
        setState(() {});
      },
      onRemove: (element) {
        _elementSubject.notifyElementDeleted(element.id);
        setState(() {});
      },
    );
    
    _commandInvoker.executeCommand(command);
    _nextId++;
  }

  void _updateClass(UmlClass updatedClass) {
    final index = _classes.indexWhere((c) => c.id == updatedClass.id);
    if (index != -1) {
      final oldClass = _classes[index];
      
      // DESIGN PATTERN: Command - Execute update command for undo/redo
      final command = UpdateElementCommand(
        oldElement: oldClass,
        newElement: updatedClass,
        elementList: _classes,
        onUpdate: (element) {
          _elementSubject.notifyElementUpdated(element);
          setState(() {});
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  void _selectClass(UmlClass? umlClass) {
    setState(() {
      if (umlClass != null && umlClass.id.isNotEmpty) {
        _selectedClass = _classes.firstWhere(
          (c) => c.id == umlClass.id,
          orElse: () => umlClass,
        );
        // DESIGN PATTERN: Observer - Notify observers of selection change
        _elementSubject.notifyElementSelected(_selectedClass);
      } else {
        _selectedClass = null;
        _elementSubject.notifyElementSelected(null);
      }
    });
  }

  void _editClass(UmlClass umlClass) async {
    final updated = await showDialog<UmlClass>(
      context: context,
      builder: (context) => TextEditorDialog(umlClass: umlClass),
    );
    if (updated != null) {
      _updateClass(updated);
    }
  }

  void _deleteSelectedClass() {
    if (_selectedClass != null) {
      final classToDelete = _selectedClass!;
      
      // DESIGN PATTERN: Command - Execute delete command for undo/redo
      final command = DeleteElementCommand(
        element: classToDelete,
        elementList: _classes,
        onAdd: (element) {
          _elementSubject.notifyElementAdded(element);
          setState(() {});
        },
        onRemove: (element) {
          _elementSubject.notifyElementDeleted(element.id);
          setState(() {
            _selectedClass = null;
          });
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  // DESIGN PATTERN: Factory - Using ElementFactoryManager to create elements
  // Activity Diagram Methods
  void _addActivityElement(ActivityElementType type) {
    final factory = ElementFactoryManager.getFactory(DiagramType.activityDiagram);
    final config = AppConfig();
    final newElement = factory.createElement(
      'activity_$_nextId',
      Offset(100 + (_activityElements.length * 50), 100 + (_activityElements.length * 50)),
      params: {
        'type': type,
        'label': type == ActivityElementType.initialState || type == ActivityElementType.finalState
            ? ''
            : type.toString().split('.').last,
        'width': config.defaultElementWidth,
        'height': config.defaultElementHeight,
      },
    ) as ActivityElement;
    
    // DESIGN PATTERN: Command - Execute add command for undo/redo
    final command = AddElementCommand(
      element: newElement,
      elementList: _activityElements,
      onAdd: (element) {
        _elementSubject.notifyElementAdded(element);
        setState(() {});
      },
      onRemove: (element) {
        _elementSubject.notifyElementDeleted(element.id);
        setState(() {});
      },
    );
    
    _commandInvoker.executeCommand(command);
    _nextId++;
  }

  void _updateActivityElement(ActivityElement element) {
    final index = _activityElements.indexWhere((e) => e.id == element.id);
    if (index != -1) {
      final oldElement = _activityElements[index];
      
      // DESIGN PATTERN: Command - Execute update command for undo/redo
      final command = UpdateElementCommand(
        oldElement: oldElement,
        newElement: element,
        elementList: _activityElements,
        onUpdate: (element) {
          _elementSubject.notifyElementUpdated(element);
          setState(() {});
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  void _selectActivityElement(ActivityElement? element) {
    setState(() {
      if (element != null && element.id.isNotEmpty) {
        _selectedActivityElement = _activityElements.firstWhere(
          (e) => e.id == element.id,
          orElse: () => element,
        );
      } else {
        _selectedActivityElement = null;
      }
    });
  }

  void _editActivityElement(ActivityElement element) async {
    final updated = await showDialog<ActivityElement>(
      context: context,
      builder: (context) => ElementEditorDialog(element: element),
    );
    if (updated != null) {
      _updateActivityElement(updated);
    }
  }

  void _deleteSelectedActivityElement() {
    if (_selectedActivityElement != null) {
      final elementToDelete = _selectedActivityElement!;
      
      // DESIGN PATTERN: Command - Execute delete command for undo/redo
      final command = DeleteElementCommand(
        element: elementToDelete,
        elementList: _activityElements,
        onAdd: (element) {
          _elementSubject.notifyElementAdded(element);
          setState(() {});
        },
        onRemove: (element) {
          _elementSubject.notifyElementDeleted(element.id);
          setState(() {
            _selectedActivityElement = null;
          });
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  // DESIGN PATTERN: Factory - Using ElementFactoryManager to create elements
  // Sequence Diagram Methods
  void _addSequenceElement(SequenceElementType type) {
    final factory = ElementFactoryManager.getFactory(DiagramType.sequenceDiagram);
    final config = AppConfig();
    final newElement = factory.createElement(
      'sequence_$_nextId',
      Offset(100 + (_sequenceElements.length * 100), 100),
      params: {
        'type': type,
        'label': type == SequenceElementType.actor ? 'Actor$_nextId' : 'Element$_nextId',
        'lifelineLength': type == SequenceElementType.lifeline ? 300.0 : null,
        'width': config.defaultElementWidth,
        'height': config.defaultElementHeight,
      },
    ) as SequenceElement;
    
    // DESIGN PATTERN: Command - Execute add command for undo/redo
    final command = AddElementCommand(
      element: newElement,
      elementList: _sequenceElements,
      onAdd: (element) {
        _elementSubject.notifyElementAdded(element);
        setState(() {});
      },
      onRemove: (element) {
        _elementSubject.notifyElementDeleted(element.id);
        setState(() {});
      },
    );
    
    _commandInvoker.executeCommand(command);
    _nextId++;
  }

  void _updateSequenceElement(SequenceElement element) {
    final index = _sequenceElements.indexWhere((e) => e.id == element.id);
    if (index != -1) {
      final oldElement = _sequenceElements[index];
      
      // DESIGN PATTERN: Command - Execute update command for undo/redo
      final command = UpdateElementCommand(
        oldElement: oldElement,
        newElement: element,
        elementList: _sequenceElements,
        onUpdate: (element) {
          _elementSubject.notifyElementUpdated(element);
          setState(() {});
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  void _selectSequenceElement(SequenceElement? element) {
    setState(() {
      if (element != null && element.id.isNotEmpty) {
        _selectedSequenceElement = _sequenceElements.firstWhere(
          (e) => e.id == element.id,
          orElse: () => element,
        );
      } else {
        _selectedSequenceElement = null;
      }
    });
  }

  void _editSequenceElement(SequenceElement element) async {
    final updated = await showDialog<SequenceElement>(
      context: context,
      builder: (context) => ElementEditorDialog(element: element),
    );
    if (updated != null) {
      _updateSequenceElement(updated);
    }
  }

  void _deleteSelectedSequenceElement() {
    if (_selectedSequenceElement != null) {
      final elementToDelete = _selectedSequenceElement!;
      
      // DESIGN PATTERN: Command - Execute delete command for undo/redo
      final command = DeleteElementCommand(
        element: elementToDelete,
        elementList: _sequenceElements,
        onAdd: (element) {
          _elementSubject.notifyElementAdded(element);
          setState(() {});
        },
        onRemove: (element) {
          _elementSubject.notifyElementDeleted(element.id);
          setState(() {
            _selectedSequenceElement = null;
          });
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  // DESIGN PATTERN: Factory - Using ElementFactoryManager to create elements
  // Use Case Diagram Methods
  void _addUseCaseElement(UseCaseElementType type) {
    final factory = ElementFactoryManager.getFactory(DiagramType.useCaseDiagram);
    final config = AppConfig();
    String label = '';
    if (type == UseCaseElementType.actor) {
      label = 'Actor$_nextId';
    } else if (type == UseCaseElementType.useCase) {
      label = 'UseCase$_nextId';
    } else if (type == UseCaseElementType.systemBoundary) {
      label = 'System';
    }
    
    final newElement = factory.createElement(
      'usecase_$_nextId',
      Offset(100 + (_useCaseElements.length * 50), 100 + (_useCaseElements.length * 50)),
      params: {
        'type': type,
        'label': label,
        'width': config.defaultElementWidth,
        'height': config.defaultElementHeight,
      },
    ) as UseCaseElement;
    
    // DESIGN PATTERN: Command - Execute add command for undo/redo
    final command = AddElementCommand(
      element: newElement,
      elementList: _useCaseElements,
      onAdd: (element) {
        _elementSubject.notifyElementAdded(element);
        setState(() {});
      },
      onRemove: (element) {
        _elementSubject.notifyElementDeleted(element.id);
        setState(() {});
      },
    );
    
    _commandInvoker.executeCommand(command);
    _nextId++;
  }

  void _updateUseCaseElement(UseCaseElement element) {
    final index = _useCaseElements.indexWhere((e) => e.id == element.id);
    if (index != -1) {
      final oldElement = _useCaseElements[index];
      
      // DESIGN PATTERN: Command - Execute update command for undo/redo
      final command = UpdateElementCommand(
        oldElement: oldElement,
        newElement: element,
        elementList: _useCaseElements,
        onUpdate: (element) {
          _elementSubject.notifyElementUpdated(element);
          setState(() {});
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  void _selectUseCaseElement(UseCaseElement? element) {
    setState(() {
      if (element != null && element.id.isNotEmpty) {
        _selectedUseCaseElement = _useCaseElements.firstWhere(
          (e) => e.id == element.id,
          orElse: () => element,
        );
      } else {
        _selectedUseCaseElement = null;
      }
    });
  }

  void _editUseCaseElement(UseCaseElement element) async {
    final updated = await showDialog<UseCaseElement>(
      context: context,
      builder: (context) => ElementEditorDialog(element: element),
    );
    if (updated != null) {
      _updateUseCaseElement(updated);
    }
  }

  void _deleteSelectedUseCaseElement() {
    if (_selectedUseCaseElement != null) {
      final elementToDelete = _selectedUseCaseElement!;
      
      // DESIGN PATTERN: Command - Execute delete command for undo/redo
      final command = DeleteElementCommand(
        element: elementToDelete,
        elementList: _useCaseElements,
        onAdd: (element) {
          _elementSubject.notifyElementAdded(element);
          setState(() {});
        },
        onRemove: (element) {
          _elementSubject.notifyElementDeleted(element.id);
          setState(() {
            _selectedUseCaseElement = null;
          });
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  // DESIGN PATTERN: Factory - Using ElementFactoryManager to create elements
  // State Machine Diagram Methods
  void _addStateMachineElement(StateMachineElementType type) {
    final factory = ElementFactoryManager.getFactory(DiagramType.stateMachineDiagram);
    final config = AppConfig();
    final newElement = factory.createElement(
      'state_$_nextId',
      Offset(100 + (_stateMachineElements.length * 50), 100 + (_stateMachineElements.length * 50)),
      params: {
        'type': type,
        'label': type == StateMachineElementType.initialState || type == StateMachineElementType.finalState
            ? ''
            : 'State$_nextId',
        'width': config.defaultElementWidth,
        'height': config.defaultElementHeight,
      },
    ) as StateMachineElement;
    
    // DESIGN PATTERN: Command - Execute add command for undo/redo
    final command = AddElementCommand(
      element: newElement,
      elementList: _stateMachineElements,
      onAdd: (element) {
        _elementSubject.notifyElementAdded(element);
        setState(() {});
      },
      onRemove: (element) {
        _elementSubject.notifyElementDeleted(element.id);
        setState(() {});
      },
    );
    
    _commandInvoker.executeCommand(command);
    _nextId++;
  }

  void _updateStateMachineElement(StateMachineElement element) {
    final index = _stateMachineElements.indexWhere((e) => e.id == element.id);
    if (index != -1) {
      final oldElement = _stateMachineElements[index];
      
      // DESIGN PATTERN: Command - Execute update command for undo/redo
      final command = UpdateElementCommand(
        oldElement: oldElement,
        newElement: element,
        elementList: _stateMachineElements,
        onUpdate: (element) {
          _elementSubject.notifyElementUpdated(element);
          setState(() {});
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  void _selectStateMachineElement(StateMachineElement? element) {
    setState(() {
      if (element != null && element.id.isNotEmpty) {
        _selectedStateMachineElement = _stateMachineElements.firstWhere(
          (e) => e.id == element.id,
          orElse: () => element,
        );
      } else {
        _selectedStateMachineElement = null;
      }
    });
  }

  void _editStateMachineElement(StateMachineElement element) async {
    final updated = await showDialog<StateMachineElement>(
      context: context,
      builder: (context) => ElementEditorDialog(element: element),
    );
    if (updated != null) {
      _updateStateMachineElement(updated);
    }
  }

  void _deleteSelectedStateMachineElement() {
    if (_selectedStateMachineElement != null) {
      final elementToDelete = _selectedStateMachineElement!;
      
      // DESIGN PATTERN: Command - Execute delete command for undo/redo
      final command = DeleteElementCommand(
        element: elementToDelete,
        elementList: _stateMachineElements,
        onAdd: (element) {
          _elementSubject.notifyElementAdded(element);
          setState(() {});
        },
        onRemove: (element) {
          _elementSubject.notifyElementDeleted(element.id);
          setState(() {
            _selectedStateMachineElement = null;
          });
        },
      );
      
      _commandInvoker.executeCommand(command);
    }
  }

  // DESIGN PATTERN: Facade - Using DiagramFacade to simplify save operations
  Future<void> _saveAsPng() async {
    try {
      final path = await DiagramFacade.saveDiagram(_repaintBoundaryKey, toGallery: true);
      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diagram saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final filePath = await DiagramFacade.saveDiagram(_repaintBoundaryKey, toGallery: false);
        if (filePath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Diagram saved to: $filePath'),
              backgroundColor: Colors.blue,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save diagram. Please check permissions.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSelectedElementPanel() {
    switch (_selectedDiagramType) {
      case DiagramType.classDiagram:
        if (_selectedClass == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected: ${_selectedClass!.className}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editClass(_selectedClass!),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deleteSelectedClass,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      
      case DiagramType.activityDiagram:
        if (_selectedActivityElement == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected: ${_selectedActivityElement!.type.toString().split('.').last}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editActivityElement(_selectedActivityElement!),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deleteSelectedActivityElement,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      
      case DiagramType.sequenceDiagram:
        if (_selectedSequenceElement == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected: ${_selectedSequenceElement!.label}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editSequenceElement(_selectedSequenceElement!),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deleteSelectedSequenceElement,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      
      case DiagramType.useCaseDiagram:
        if (_selectedUseCaseElement == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected: ${_selectedUseCaseElement!.label}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editUseCaseElement(_selectedUseCaseElement!),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deleteSelectedUseCaseElement,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      
      case DiagramType.stateMachineDiagram:
        if (_selectedStateMachineElement == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected: ${_selectedStateMachineElement!.label.isEmpty ? _selectedStateMachineElement!.type.toString().split('.').last : _selectedStateMachineElement!.label}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editStateMachineElement(_selectedStateMachineElement!),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deleteSelectedStateMachineElement,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UMLify - ${_selectedDiagramType.displayName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // DESIGN PATTERN: Command - Undo/Redo buttons
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _commandInvoker.canUndo() ? () {
              _commandInvoker.undo();
              setState(() {});
            } : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: _commandInvoker.canRedo() ? () {
              _commandInvoker.redo();
              setState(() {});
            } : null,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save as PNG',
            onPressed: _saveAsPng,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Diagram Type Selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagram Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<DiagramType>(
                        value: _selectedDiagramType,
                        isExpanded: true,
                        items: DiagramType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                        onChanged: (type) {
                          if (type != null) {
                            _switchDiagramType(type);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Component Panel
                Expanded(
                  child: DiagramComponentPanel(
                    diagramType: _selectedDiagramType,
                    onAddClass: _addClass,
                    onAddInitialState: () => _addActivityElement(ActivityElementType.initialState),
                    onAddAction: () => _addActivityElement(ActivityElementType.action),
                    onAddDecision: () => _addActivityElement(ActivityElementType.decision),
                    onAddFork: () => _addActivityElement(ActivityElementType.fork),
                    onAddJoin: () => _addActivityElement(ActivityElementType.join),
                    onAddFinalState: () => _addActivityElement(ActivityElementType.finalState),
                    onAddActor: () {
                      if (_selectedDiagramType == DiagramType.sequenceDiagram) {
                        _addSequenceElement(SequenceElementType.actor);
                      } else {
                        _addUseCaseElement(UseCaseElementType.actor);
                      }
                    },
                    onAddLifeline: () => _addSequenceElement(SequenceElementType.lifeline),
                    onAddMessage: () => _addSequenceElement(SequenceElementType.message),
                    onAddActivationBar: () => _addSequenceElement(SequenceElementType.activationBar),
                    onAddUseCase: () => _addUseCaseElement(UseCaseElementType.useCase),
                    onAddAssociation: () => _addUseCaseElement(UseCaseElementType.association),
                    onAddSystemBoundary: () => _addUseCaseElement(UseCaseElementType.systemBoundary),
                    onAddState: () => _addStateMachineElement(StateMachineElementType.state),
                    onAddTransition: () => _addStateMachineElement(StateMachineElementType.transition),
                  ),
                ),
                // Selected Element Panel
                _buildSelectedElementPanel(),
                const Spacer(),
                // Instructions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Instructions:\n\n'
                    '1. Select diagram type from dropdown\n'
                    '2. Click component buttons to add elements\n'
                    '3. Drag elements to reposition\n'
                    '4. Click elements to select\n'
                    '5. Click "Save" to export as PNG',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Canvas area
          Expanded(
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Container(
                color: Colors.white,
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  // DESIGN PATTERN: Singleton - Using AppConfig for scale values
                  minScale: _config.minScale,
                  maxScale: _config.maxScale,
                  child: SizedBox(
                    // DESIGN PATTERN: Singleton - Using AppConfig for canvas size
                    width: _config.canvasWidth,
                    height: _config.canvasHeight,
                    child: UnifiedUmlCanvas(
                      diagramType: _selectedDiagramType,
                      classes: _classes,
                      activityElements: _activityElements,
                      sequenceElements: _sequenceElements,
                      useCaseElements: _useCaseElements,
                      stateMachineElements: _stateMachineElements,
                      onClassUpdate: _updateClass,
                      onClassSelect: _selectClass,
                      onActivityElementUpdate: _updateActivityElement,
                      onActivityElementSelect: _selectActivityElement,
                      onSequenceElementUpdate: _updateSequenceElement,
                      onSequenceElementSelect: _selectSequenceElement,
                      onUseCaseElementUpdate: _updateUseCaseElement,
                      onUseCaseElementSelect: _selectUseCaseElement,
                      onStateMachineElementUpdate: _updateStateMachineElement,
                      onStateMachineElementSelect: _selectStateMachineElement,
                      repaintBoundaryKey: _repaintBoundaryKey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
