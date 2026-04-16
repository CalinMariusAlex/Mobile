import 'package:flutter/material.dart';
import '../services/skill_service.dart';

class AddTaskPage extends StatefulWidget {
  final String skillId;

  const AddTaskPage({
    super.key,
    required this.skillId,
  });

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetLevelController = TextEditingController(text: '2');

  final SkillService _skillService = SkillService();

  String _selectedType = 'read';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetLevelController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final targetLevel = int.tryParse(_targetLevelController.text.trim()) ?? 2;

      if (title.isEmpty) {
        throw Exception('Task title cannot be empty.');
      }

      await _skillService.addTask(
        skillId: widget.skillId,
        title: title,
        type: _selectedType,
        description: description,
        targetLevel: targetLevel,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'read', child: Text('Read')),
                DropdownMenuItem(value: 'test', child: Text('Test')),
                DropdownMenuItem(value: 'travel', child: Text('Travel')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Task type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetLevelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target level',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}