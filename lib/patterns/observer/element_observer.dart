// DESIGN PATTERN: Observer Pattern
// Defines a one-to-many dependency between objects so when one changes, all are notified
// Used in: State change notifications, UI updates, element selection

abstract class ElementObserver {
  void onElementSelected(dynamic element);
  void onElementUpdated(dynamic element);
  void onElementDeleted(String elementId);
  void onElementAdded(dynamic element);
}

class ElementSubject {
  final List<ElementObserver> _observers = [];
  dynamic _selectedElement;
  
  void attach(ElementObserver observer) {
    _observers.add(observer);
  }
  
  void detach(ElementObserver observer) {
    _observers.remove(observer);
  }
  
  void notifyElementSelected(dynamic element) {
    _selectedElement = element;
    for (var observer in _observers) {
      observer.onElementSelected(element);
    }
  }
  
  void notifyElementUpdated(dynamic element) {
    for (var observer in _observers) {
      observer.onElementUpdated(element);
    }
  }
  
  void notifyElementDeleted(String elementId) {
    if (_selectedElement != null && _getElementId(_selectedElement) == elementId) {
      _selectedElement = null;
    }
    for (var observer in _observers) {
      observer.onElementDeleted(elementId);
    }
  }
  
  void notifyElementAdded(dynamic element) {
    for (var observer in _observers) {
      observer.onElementAdded(element);
    }
  }
  
  String? _getElementId(dynamic element) {
    if (element == null) return null;
    try {
      return element.id as String?;
    } catch (e) {
      return null;
    }
  }
  
  dynamic get selectedElement => _selectedElement;
}

