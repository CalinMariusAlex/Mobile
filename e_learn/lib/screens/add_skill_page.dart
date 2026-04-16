import 'package:flutter/material.dart';
import '../services/skill_service.dart';

class AddSkillPage extends StatefulWidget {
  const AddSkillPage({super.key});

  @override
  State<AddSkillPage> createState() => _AddSkillPageState();
}

class _AddSkillPageState extends State<AddSkillPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxLevelController = TextEditingController(text: '5');

  final SkillService _skillService = SkillService();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxLevelController.dispose();
    super.dispose();
  }

  Future<void> _saveSkill() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final maxLevel = int.tryParse(_maxLevelController.text.trim()) ?? 5;

      if (name.isEmpty) {
        throw Exception('Skill name cannot be empty.');
      }

      await _skillService.addSkill(
        name: name,
        description: description,
        maxLevel: maxLevel,
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
        title: const Text('Add Skill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Skill name',
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
              controller: _maxLevelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max level',
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
                onPressed: _isLoading ? null : _saveSkill,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Skill'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}