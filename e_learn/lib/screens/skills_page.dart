import 'package:flutter/material.dart';
import '../services/skill_service.dart';
import 'add_skill_page.dart';
import 'skill_details_page.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final skillService = SkillService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Skills'),
      ),
      body: StreamBuilder(
        stream: skillService.getSkills(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('No skills yet. Add your first skill.'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final skillDoc = docs[index];
              final data = skillDoc.data();

              final String name = data['name'] ?? 'Unnamed skill';
              final String description = data['description'] ?? '';
              final int currentLevel = data['currentLevel'] ?? 1;
              final int maxLevel = data['maxLevel'] ?? 5;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(
                    '$description\nLevel: $currentLevel / $maxLevel',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SkillDetailsPage(
                          skillId: skillDoc.id,
                          skillName: name,
                          skillDescription: description,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSkillPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}