import 'package:flutter/material.dart';
import '../services/auth_service.dart';

import 'my_account_page.dart';
import 'edit_profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('E-Learning Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await auth.logout();
                // AuthGate will send you back to Login
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My account'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyAccountPage()),
                );
              },
              ),
              ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Welcome!')),
    );
  }
}