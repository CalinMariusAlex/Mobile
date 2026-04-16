import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/skill_service.dart';
import 'add_task_page.dart';

class SkillDetailsPage extends StatelessWidget {
  final String skillId;
  final String skillName;
  final String skillDescription;

  const SkillDetailsPage({
    super.key,
    required this.skillId,
    required this.skillName,
    required this.skillDescription,
  });

  @override
  Widget build(BuildContext context) {
    final skillService = SkillService();

    return Scaffold(
      appBar: AppBar(
        title: Text(skillName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              skillDescription,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: skillService.getTasks(skillId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No tasks yet for this skill.'),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final taskDoc = docs[index];
                    final data = taskDoc.data();

                    final title = data['title'] ?? 'Untitled task';
                    final type = data['type'] ?? '';
                    final description = data['description'] ?? '';
                    final targetLevel = data['targetLevel'] ?? 1;
                    final isCompleted = data['isCompleted'] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(
                          'Type: $type\nTarget level: $targetLevel\n$description',
                        ),
                        isThreeLine: true,
                        trailing: isCompleted
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : ElevatedButton(
                                onPressed: () async {
                                  await skillService.completeTask(
                                    skillId: skillId,
                                    taskId: taskDoc.id,
                                  );
                                },
                                child: const Text('Complete'),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskPage(skillId: skillId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}