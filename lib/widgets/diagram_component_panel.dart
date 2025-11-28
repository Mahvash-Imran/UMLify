import 'package:flutter/material.dart';
import '../models/diagram_type.dart';

class DiagramComponentPanel extends StatelessWidget {
  final DiagramType diagramType;
  final VoidCallback? onAddInitialState;
  final VoidCallback? onAddAction;
  final VoidCallback? onAddDecision;
  final VoidCallback? onAddFork;
  final VoidCallback? onAddJoin;
  final VoidCallback? onAddFinalState;
  final VoidCallback? onAddActor;
  final VoidCallback? onAddLifeline;
  final VoidCallback? onAddMessage;
  final VoidCallback? onAddActivationBar;
  final VoidCallback? onAddUseCase;
  final VoidCallback? onAddAssociation;
  final VoidCallback? onAddSystemBoundary;
  final VoidCallback? onAddState;
  final VoidCallback? onAddTransition;
  final VoidCallback? onAddClass;

  const DiagramComponentPanel({
    super.key,
    required this.diagramType,
    this.onAddInitialState,
    this.onAddAction,
    this.onAddDecision,
    this.onAddFork,
    this.onAddJoin,
    this.onAddFinalState,
    this.onAddActor,
    this.onAddLifeline,
    this.onAddMessage,
    this.onAddActivationBar,
    this.onAddUseCase,
    this.onAddAssociation,
    this.onAddSystemBoundary,
    this.onAddState,
    this.onAddTransition,
    this.onAddClass,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Components',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            children: _buildComponentButtons(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildComponentButtons() {
    switch (diagramType) {
      case DiagramType.classDiagram:
        return [
          _buildButton(
            icon: Icons.class_,
            label: 'Add Class',
            onPressed: onAddClass,
          ),
        ];
      
      case DiagramType.activityDiagram:
        return [
          _buildButton(
            icon: Icons.radio_button_checked,
            label: 'Initial State',
            onPressed: onAddInitialState,
          ),
          _buildButton(
            icon: Icons.rounded_corner,
            label: 'Action',
            onPressed: onAddAction,
          ),
          _buildButton(
            icon: Icons.change_circle,
            label: 'Decision',
            onPressed: onAddDecision,
          ),
          _buildButton(
            icon: Icons.horizontal_split,
            label: 'Fork',
            onPressed: onAddFork,
          ),
          _buildButton(
            icon: Icons.merge_type,
            label: 'Join',
            onPressed: onAddJoin,
          ),
          _buildButton(
            icon: Icons.cancel,
            label: 'Final State',
            onPressed: onAddFinalState,
          ),
        ];
      
      case DiagramType.sequenceDiagram:
        return [
          _buildButton(
            icon: Icons.person,
            label: 'Actor',
            onPressed: onAddActor,
          ),
          _buildButton(
            icon: Icons.vertical_align_center,
            label: 'Lifeline',
            onPressed: onAddLifeline,
          ),
          _buildButton(
            icon: Icons.arrow_forward,
            label: 'Message',
            onPressed: onAddMessage,
          ),
          _buildButton(
            icon: Icons.rectangle,
            label: 'Activation Bar',
            onPressed: onAddActivationBar,
          ),
        ];
      
      case DiagramType.useCaseDiagram:
        return [
          _buildButton(
            icon: Icons.person,
            label: 'Actor',
            onPressed: onAddActor,
          ),
          _buildButton(
            icon: Icons.circle_outlined,
            label: 'Use Case',
            onPressed: onAddUseCase,
          ),
          _buildButton(
            icon: Icons.link,
            label: 'Association',
            onPressed: onAddAssociation,
          ),
          _buildButton(
            icon: Icons.border_outer,
            label: 'System Boundary',
            onPressed: onAddSystemBoundary,
          ),
        ];
      
      case DiagramType.stateMachineDiagram:
        return [
          _buildButton(
            icon: Icons.radio_button_checked,
            label: 'Initial State',
            onPressed: onAddInitialState,
          ),
          _buildButton(
            icon: Icons.rounded_corner,
            label: 'State',
            onPressed: onAddState,
          ),
          _buildButton(
            icon: Icons.cancel,
            label: 'Final State',
            onPressed: onAddFinalState,
          ),
          _buildButton(
            icon: Icons.arrow_forward,
            label: 'Transition',
            onPressed: onAddTransition,
          ),
        ];
    }
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}


